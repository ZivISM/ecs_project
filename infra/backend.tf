# terraform {
#   backend "s3" {
#     bucket         = "sign-now-terraform-state"
#     key            = "terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
