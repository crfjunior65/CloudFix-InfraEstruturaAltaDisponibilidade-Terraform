
/* Conditional EC2 Module
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
==========================================================
*/
resource "aws_instance" "ec2" {
  #depends_on = [aws_key_pair.deployer]

  # A AMI é obtida através de um data source, o que é uma boa prática.
  ami           = var.ami_id
  instance_type = var.instance_type

  # Configuração do volume raiz (EBS)
  root_block_device {
    volume_size           = 15    # Tamanho em GiB (padrão: 8GB para muitas AMIs)
    volume_type           = "gp3" # Tipo de volume (gp2, gp3, io1, etc.)
    encrypted             = true  # Garante que o volume seja criptografado
    delete_on_termination = true
  }

  key_name = var.key_name

  #availability_zone = module.vpc.azs_id[0]
  subnet_id = var.public_subnet_ids[0]

  associate_public_ip_address = true

  # O script user_data é a maneira recomendada de configurar uma instância no boot.
  # A lógica que estava nos provisioners deve ser movida para este ou um script similar.
  #user_data = file("InstallDev.sh")
  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint     = var.db_endpoint
    valkey_endpoint = var.valkey_endpoint
    ecr_repository  = var.ecr_repository
    aws_region      = var.aws_region
  }))

  #iam_instance_profile = data.terraform_remote_state.iam.outputs.iam_ssm_profile.id
  iam_instance_profile = aws_iam_instance_profile.app_profile.name

  /*
  tags = {
    Name        = "Bia-Dev" #BastionHost"
    Terraform   = "true"
    AZ          = data.terraform_remote_state.vpc.outputs.vpc_azs_id[0]
    Environment = "Projeto-${var.Environment}"
    Management  = "Terraform"
  }
  */
  #tags = {
  #resource_type = "instance"
  tags = merge(var.tags, {
    Name = "${var.prefix}-app-instance"
    Type = "Application"
  })
  #}
  # Sintaxe moderna para listas, sem a interpolação "${...}"
  #vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.sg_bia_dev]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
}


# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.prefix}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-alb-sg"
  })
}

# Security Group for App Instances
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.prefix}-app-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ####security_groups = [aws_security_group.alb_sg.id]
    ####security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-app-sg"
  })
}

# IAM Role for EC2 instances
resource "aws_iam_role" "app_role" {
  name = "${var.prefix}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for ECR access
resource "aws_iam_role_policy" "app_ecr_policy" {
  name = "${var.prefix}-app-ecr-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Anexar a política gerenciada AmazonSSMManagedInstanceCore ao Role
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Anexar a política gerenciada AmazonS3FullAccess ao Role
resource "aws_iam_role_policy_attachment" "s3_full_ssm" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Anexar a política gerenciada AmazonRDSFullAccess ao Role
resource "aws_iam_role_policy_attachment" "rds_full_acess_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Anexar a política gerenciada AmazonEC2ContainerRegistryFullAccess ao Role
resource "aws_iam_role_policy_attachment" "ec2_container_registry_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}


# Instance Profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.prefix}-app-profile"
  role = aws_iam_role.app_role.name

  tags = var.tags
}
