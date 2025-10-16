# Configurações AWS
region = "us-east-1"

# Compute Configuration
enable_ec2 = true
enable_ecs = false

# Project Configuration
project_name = "dolfy"
prefix       = "dolfy"
environment  = "hml"

# EC2 Configuration
ec2_instance_type    = "t3.micro"
ec2_min_size         = 1
ec2_max_size         = 4
ec2_desired_capacity = 1

# ECS Configuration (EC2-based)
ecs_instance_type    = "t3.micro"
ecs_min_size         = 1
ecs_max_size         = 4
ecs_desired_capacity = 2

# Network Configuration
vpc_cidr = "10.100.0.0/16"
num_azs  = 2

# RDS Configuration
rds_instance_class = "db.t3.micro"
rds_storage        = 50
db_name            = "dolfy"
db_username        = "dolfy"
db_password        = "dolfy_password"

# Valkey Configuration
valkey_engine_version = "8.0"
valkey_num_nodes      = 1
valkey_node_type      = "cache.t3.micro"

# Bastion Configuration
bastion_instance_type = "t3.micro"
# Key Configuration
auto_generate_key = true
key_name          = "aws-key-terraform"
aws_eip_public_ip = "3.220.103.33"

# Monitoring Configuration
monitoring_sns_topic_arn = ""
monitored_services = [
  {
    name          = "dolfy-app"
    namespace     = "default"
    min_pod_count = 2
    cpu_threshold = 80
    mem_threshold = 80
  }
]

# Testing Configuration
deploy_test_app = true

# Tags Configuration
tags = {
  Environment = "homologation"
  Projeto     = "dolfy"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
