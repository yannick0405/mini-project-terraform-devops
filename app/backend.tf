terraform {
  backend "s3" {
    bucket         = "yannick-mini-project-terraform-tfstate"
    key            = "mini-project-terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mini-project-terraform-locks"
    encrypt        = true
  }
}