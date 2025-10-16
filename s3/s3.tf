#____________________________________________________________________________
#-------------------------------- Bucket S3 ---------------------------------
#____________________________________________________________________________

resource "aws_s3_bucket" "s3" {
  bucket = var.projectName
  #Access Logging
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption" {
  bucket = aws_s3_bucket.s3.id

  rule {
    bucket_key_enabled = true
  }
}

variable "regionProject" {
  description = "Define a região de execuçaõ do projeto"
  default     = "us-east-1"
}

variable "projectName" {
  description = "Nome do projeto -Sera usado para criar o nome da task, service, roles e container-"
  default     = "dolfy-shield-tfstate"
}

variable "tags" {
  description = "Tags padrão para o bucket S3"
  type        = map(string)
  default = {
    Environment = "homologation"
    Projeto     = "dolfy"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
}
