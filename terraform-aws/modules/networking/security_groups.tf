# Security Group para aplicação
resource "aws_security_group" "app" {
  name        = format("%s-app-sg", var.prefix)
  description = "Security group para a aplicacao"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-app-sg-%s", var.prefix, var.environment)
    }
  )
}

# Regras de entrada para a aplicação
resource "aws_security_group_rule" "app_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS traffic to application"
}

resource "aws_security_group_rule" "app_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP traffic to application"
}

resource "aws_security_group_rule" "app_ingress_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.app.id
  description       = "Allow internal traffic between application instances"
}

# Regras de saída para a aplicação
resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic from application"
}

# Security Group para o RDS
resource "aws_security_group" "rds" {
  name        = format("%s-rds-sg-%s", var.prefix, var.environment)
  description = "Security group para o RDS"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-rds-sg-%s", var.prefix, var.environment)
    }
  )
}

# Regras de entrada para o RDS (permite acesso da aplicação)
resource "aws_security_group_rule" "rds_ingress_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow PostgreSQL access from application"
}

# Regras de saída para o RDS
resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Permite todo o trafego de saida do RDS"
}
