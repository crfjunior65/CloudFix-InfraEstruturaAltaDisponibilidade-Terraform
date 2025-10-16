# Key Pair Outputs (only if auto-generated)
output "ssh_key_name" {
  description = "Name of the SSH key pair (auto-generated or existing)"
  value       = var.auto_generate_key ? module.key_pair[0].key_name : var.key_name
}

output "ssh_private_key_path" {
  description = "Path to the private key file (only if auto-generated)"
  value       = var.auto_generate_key ? module.key_pair[0].private_key_path : "Using existing key: ${var.key_name}"
}

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

# Cache Outputs
output "valkey_endpoint" {
  description = "Valkey cluster endpoint"
  value       = module.valkey.valkey_endpoint
}

# ECR Output
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}
