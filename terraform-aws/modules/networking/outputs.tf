output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "app_private_subnet_ids" {
  description = "IDs das subnets privadas da aplicação"
  value       = aws_subnet.app_private[*].id
}

output "rds_private_subnet_ids" {
  description = "IDs das subnets privadas do RDS"
  value       = aws_subnet.rds_private[*].id
}

output "nat_gateway_ip" {
  description = "IP do NAT Gateway"
  value       = aws_nat_gateway.main.public_ip
}

output "app_security_group_id" {
  description = "ID do Security Group da aplicação"
  value       = aws_security_group.app.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}

output "lb_security_group_id" {
  description = "ID do Security Group do Load Balancer"
  value       = aws_security_group.lb.id
}
