terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "env/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
