# =============================================================================
# Exemplo de Variáveis do Terraform para a Plataforma CloudFix
#
# Copie este arquivo para "terraform.tfvars" e preencha com os valores desejados.
# `terraform.tfvars` NÃO deve ser versionado no Git.
# =============================================================================

# -----------------------------------------------------------------------------
# Configurações Gerais do Ambiente
# -----------------------------------------------------------------------------

# Região da AWS onde a infraestrutura será criada.
aws_region = "us-east-1"

# Nome do ambiente (e.g., "dev", hml, "qa", "staging", "prod"). Usado para nomear recursos.
environment = "dev"

# Nome do projeto. Usado como prefixo para vários recursos.
project_name = "CloudFix"

# Tags comuns a serem aplicadas em todos os recursos que suportam tagging.
common_tags = {
  Project     = "CloudFix Platform"
  ManagedBy   = "Terraform"
  Environment = "development"
}

# -----------------------------------------------------------------------------
# Configurações de Rede (Módulo Networking)
# -----------------------------------------------------------------------------

# Bloco CIDR para a VPC. Escolha um intervalo que não conflite com outras redes.
vpc_cidr = "10.100.0.0/16"

### Subnets Gerados Dinamicamente
# Blocos CIDR para as subnets públicas. Geralmente usadas para Load Balancers e Bastion Hosts.

## public_subnets_cidr = ["10.100.1.0/24", "10.100.2.0/24"]

# Blocos CIDR para as subnets privadas. Onde a aplicação e o banco de dados irão rodar.
## private_subnets_cidr = ["10.100.10.0/24", "10.100.11.0/24"]

# -----------------------------------------------------------------------------
# Configurações do Alvo de Implantação (EC2 ou ECS)
# -----------------------------------------------------------------------------

# Defina o alvo da implantação. Valores válidos: "ecs" ou "ec2".
deployment_target = "ecs"

# Configurações para EC2 (usadas apenas se deployment_target = "ec2")
# -----------------------------------------------------------------------------
e_ec2_instance_type = "t3.micro"

# Configurações para ECS (usadas apenas se deployment_target = "ecs")
# -----------------------------------------------------------------------------
ecs_task_cpu    = 256  # Unidades de CPU para a tarefa ECS (1024 = 1 vCPU)
ecs_task_memory = 512  # Memória em MB para a tarefa ECS
ecs_desired_count = 1    # Número de instâncias da tarefa que devem estar rodando

# -----------------------------------------------------------------------------
# Configurações do Banco de Dados (Módulo RDS)
# -----------------------------------------------------------------------------

rds_instance_class    = "db.t3.micro"
rds_allocated_storage = 20
rds_engine_version    = "14.6"
rds_db_name           = "CloudFixdb"
rds_db_username       = "admin"

# ATENÇÃO: Para a senha, é altamente recomendável usar um cofre de segredos
# (como AWS Secrets Manager) em vez de texto plano.
# Para desenvolvimento, você pode definir aqui, mas não versione em produção.
# rds_db_password       = "sua-senha-super-secreta"

# -----------------------------------------------------------------------------
# Configurações do Agendador do RDS (Módulo rds-scheduler)
# -----------------------------------------------------------------------------

# Habilita ou desabilita o agendador de start/stop do RDS.
enable_rds_scheduler = true

# Expressão cron para parar a instância (e.g., todos os dias às 22:00 UTC).
rds_schedule_stop = "cron(0 22 * * ? *)"

# Expressão cron para iniciar a instância (e.g., todos os dias às 08:00 UTC).
rds_schedule_start = "cron(0 8 * * ? *)"
