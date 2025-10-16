# Project Configuration
variable "prefix" {
  description = "Prefix to project name"
  type        = string
}

variable "project_name" {
  description = "Name to project for tagging and identification purposes"
  type        = string
}

variable "environment" {
  description = "Deployment environment name, such as 'dev', 'hml', 'stag', or 'prod'"
  type        = string
}

variable "region" {
  description = "Region AWS where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

# Compute Configuration
variable "enable_ec2" {
  description = "Enable EC2 instances for the application"
  type        = bool
  default     = true
}

variable "enable_ecs" {
  description = "Enable ECS cluster for the application"
  type        = bool
  default     = false
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "Tipo de instância EC2 para aplicação"
  type        = string
  default     = "t3.medium"
}

variable "ec2_min_size" {
  description = "Número mínimo de instâncias EC2"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Número máximo de instâncias EC2"
  type        = number
  default     = 4
}

variable "ec2_desired_capacity" {
  description = "Número desejado de instâncias EC2"
  type        = number
  default     = 2
}

# ECS Configuration (EC2-based)
variable "ecs_instance_type" {
  description = "Tipo de instância EC2 para ECS"
  type        = string
  default     = "t3.medium"
}

variable "ecs_min_size" {
  description = "Número mínimo de instâncias ECS"
  type        = number
  default     = 1
}

variable "ecs_max_size" {
  description = "Número máximo de instâncias ECS"
  type        = number
  default     = 4
}

variable "ecs_desired_capacity" {
  description = "Número desejado de instâncias ECS"
  type        = number
  default     = 2
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  #default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of Availability Zones for use (2 or 3)"
  type        = number
  default     = 2
}

# RDS Configuration
variable "rds_instance_class" {
  description = "Classe da instância RDS"
  type        = string
}

variable "rds_storage" {
  description = "Armazenamento inicial do RDS em GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "pbet-postgres"
}

variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
  default     = "pbet"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

# Valkey Configuration
variable "valkey_node_type" {
  description = "Tipo de instância para o Valkey"
  type        = string
  default     = "cache.t3.micro"
}

variable "valkey_num_nodes" {
  description = "Number of Valkey cache nodes"
  type        = number
  default     = 2
}

variable "valkey_engine_version" {
  description = "Valkey engine version"
  type        = string
  default     = "8.0"
}

# Bastion Configuration
variable "bastion_instance_type" {
  description = "Tipo de instância para o Bastion Host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do par de chaves SSH para acesso às instâncias EC2"
  type        = string
  default     = "aws-key-terraform"
}

variable "auto_generate_key" {
  description = "Automatically generate SSH key pair instead of using existing one"
  type        = bool
  default     = false
}

variable "aws_eip_public_ip" {
  description = "Public IP of the existing Elastic IP to associate with the bastion host"
  type        = string
}

# Monitoring Configuration
variable "monitoring_sns_topic_arn" {
  description = "Opcional: O ARN de um tópico SNS para notificações dos alarmes do CloudWatch"
  type        = string
  default     = ""
}

variable "monitored_services" {
  description = "Uma lista de serviços específicos para criar alarmes detalhados"
  type = list(object({
    name          = string
    namespace     = string
    min_pod_count = number
    cpu_threshold = number
    mem_threshold = number
  }))
}

# Testing Configuration
variable "deploy_test_app" {
  description = "Deploy aplicação de teste. Em produção: false"
  type        = bool
  default     = true
}

# Tags Configuration
variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    Environment = "homologation"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
    Projeto     = "CloudFix"
  }
}
