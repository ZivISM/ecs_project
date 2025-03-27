###############################################################################
# ECR
###############################################################################

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  create = var.create_ecr

  repository_name = "${var.registry_name}-${var.env}"

  repository_read_write_access_arns = [aws_iam_role.ecs_task_execution_role.arn]
  
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = var.registry_tags

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}