# Optional Key Pair Module (only if auto_generate_key = true)
module "key_pair" {
  count  = var.auto_generate_key ? 1 : 0
  source = "./modules/key-pair"

  prefix      = local.prefix_project
  environment = local.environment
  tags        = var.tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr

  subnets_public      = local.public_subnets_cidrs
  app_private_subnets = local.app_subnets_cidrs
  rds_private_subnets = local.rds_subnets_cidrs
  prefix              = local.prefix_project
  environment         = local.environment

  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.num_azs)

  tags = var.tags
}

# Conditional EC2 Module
module "ec2" {
  count  = var.enable_ec2 ? 1 : 0
  source = "./modules/ec2"

  prefix             = local.prefix_project
  environment        = local.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.app_private_subnet_ids

  instance_type    = var.ec2_instance_type
  min_size         = var.ec2_min_size
  max_size         = var.ec2_max_size
  desired_capacity = var.ec2_desired_capacity
  key_name         = var.auto_generate_key ? module.key_pair[0].key_name : var.key_name

  db_endpoint     = module.rds.db_instance_endpoint
  valkey_endpoint = module.valkey.valkey_endpoint
  ecr_repository  = module.ecr.repository_url
  aws_region      = var.region

  tags = var.tags
}

# Conditional ECS Module
module "ecs" {
  count  = var.enable_ecs ? 1 : 0
  source = "./modules/ecs"

  prefix             = local.prefix_project
  environment        = local.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.app_private_subnet_ids

  ecr_repository  = module.ecr.repository_url
  db_endpoint     = module.rds.db_instance_endpoint
  valkey_endpoint = module.valkey.valkey_endpoint
  aws_region      = var.region
  key_name        = var.auto_generate_key ? module.key_pair[0].key_name : var.key_name

  instance_type    = var.ecs_instance_type
  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size
  desired_capacity = var.ecs_desired_capacity

  tags = var.tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.rds_private_subnet_ids
  security_group_ids = [module.networking.rds_security_group_id]
  prefix             = local.prefix_project
  environment        = local.environment

  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_storage
  max_allocated_storage   = 100
  backup_retention_period = 7

  # Para EC2/ECS, usamos o security group da aplicação
  eks_cluster_security_group_id = module.networking.app_security_group_id
  skip_final_snapshot           = true

  tags = var.tags
}

# Valkey Module
module "valkey" {
  source = "./modules/valkey"

  prefix             = local.prefix_project
  project_name       = var.project_name
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.rds_private_subnet_ids
  environment        = local.environment

  node_type       = var.valkey_node_type
  num_cache_nodes = var.valkey_num_nodes
  engine_version  = var.valkey_engine_version

  # Para EC2/ECS, usamos o security group da aplicação
  eks_security_group_id = module.networking.app_security_group_id

  tags = var.tags
}

# RDS Scheduler Module
module "rds_scheduler" {
  source = "./modules/rds-scheduler"

  prefix                 = local.prefix_project
  project_name           = var.project_name
  db_instance_identifier = module.rds.db_instance_id
  aws_region             = var.region
  environment            = local.environment

  tags = var.tags
}

# # Bastion Host Module
# module "bastion_host" {
#   source                = "./modules/bastion_host"
#   prefix                = local.prefix_project
#   project_name          = var.project_name
#   bastion_instance_type = var.bastion_instance_type
#   key_name              = var.key_name
#   tags                  = var.tags
#   environment           = local.environment
#   aws_eip_public_ip     = var.aws_eip_public_ip

#   vpc_id                = module.networking.vpc_id
#   public_subnet_id      = module.networking.public_subnet_ids[0]
#   rds_security_group_id = module.networking.rds_security_group_id
# }

# # Bastion Scheduler Module
# module "bastion_scheduler" {
#   source = "./modules/bastion-scheduler"

#   prefix              = local.prefix_project
#   project_name        = var.project_name
#   bastion_instance_id = module.bastion_host.bastion_instance_id
#   aws_region          = var.region
#   environment         = local.environment

#   tags = var.tags
# }

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  prefix      = local.prefix_project
  environment = local.environment

  tags = var.tags
}

# # Monitoring Module
# module "monitoring" {
#   source = "./modules/monitoring"

#   cluster_name             = "${local.prefix_project}-${var.compute_type}"
#   node_group_asg_name      = var.compute_type == "ec2" ? module.ec2[0].autoscaling_group_name : (var.compute_type == "ecs" ? module.ecs[0].autoscaling_group_name : null)
#   db_instance_identifier   = module.rds.db_instance_id
#   sns_topic_arn_for_alarms = var.monitoring_sns_topic_arn
#   prefix                   = local.prefix_project

#   services_to_monitor = var.monitored_services
# }

# # CloudWatch Dashboard
# resource "aws_cloudwatch_dashboard" "pbet_dashboard" {
#   dashboard_name = "${local.prefix_project}-${local.environment}-dashboard"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 12
#         height = 6

#         properties = {
#           metrics = var.compute_type == "ec2" ? [
#             ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.ec2[0].autoscaling_group_name],
#             ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", split("/", module.ec2[0].alb_arn)[1]]
#             ] : [
#             ["AWS/ECS", "CPUUtilization", "ServiceName", module.ecs[0].service_name, "ClusterName", module.ecs[0].cluster_name],
#             ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.ecs[0].autoscaling_group_name]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = var.region
#           title   = "${upper(var.compute_type)} Metrics"
#           period  = 300
#         }
#       }
#     ]
#   })
# }
