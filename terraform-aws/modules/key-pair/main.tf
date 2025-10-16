# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.prefix}-${var.environment}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = var.tags
}

# Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.root}/keys/${var.prefix}-${var.environment}-key.pem"

  file_permission = "0600"
}
