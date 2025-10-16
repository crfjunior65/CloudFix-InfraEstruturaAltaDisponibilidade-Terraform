/*locals {
  repositories = [
    "webapp/pbet-front",
    "webapp/pbet-back",
    "backoffice/pbet-front",
    "backoffice/pbet-back"
  ]
}*/

resource "aws_ecr_repository" "repositories" {
  #for_each = toset(local.repositories)

  #name                 = "${var.prefix}-${each.key}"
  name = "${var.prefix}-${var.environment}"
  #name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  #for_each   = aws_ecr_repository.repositories
  #repository = each.value.name
  repository = aws_ecr_repository.repositories.name
  # "${var.prefix}-${var.environment}"

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
