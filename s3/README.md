<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.s3-encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_projectName"></a> [projectName](#input\_projectName) | Nome do projeto -Sera usado para criar o nome da task, service, roles e container- | `string` | `"dolfy-shield-tfstate"` | no |
| <a name="input_regionProject"></a> [regionProject](#input\_regionProject) | Define a região de execuçaõ do projeto | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags padrão para o bucket S3 | `map(string)` | <pre>{<br>  "Environment": "homologation",<br>  "ManagedBy": "terraform",<br>  "Owner": "devops-team",<br>  "Projeto": "dolfy"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
