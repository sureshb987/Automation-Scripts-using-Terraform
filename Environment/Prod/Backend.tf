terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "env/${var.environment}/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
