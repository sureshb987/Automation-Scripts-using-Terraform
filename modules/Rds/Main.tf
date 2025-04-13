provider "aws" {
  region = "ap-south-1"
}
# Create a subnet group for the RDS instance
resource "aws_db_subnet_group" "CorporateProject_db_subnet_group" {
  name       = "corporateproject-db-subnet-group"
  subnet_ids = aws_subnet.CorporateProject_subnet[*].id

  tags = {
    Name = "CorporateProject DB Subnet Group"
  }
}

# Security group for RDS allowing MySQL access
resource "aws_security_group" "CorporateProject_rds_sg" {
  name        = "corporateproject-rds-sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.CorporateProject_vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CorporateProject RDS SG"
  }
}

# RDS MySQL instance
resource "aws_db_instance" "corporateproject_mysql" {
  identifier             = "corporateproject-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "CorporateProject_db"
  username               = "admin"
  password               = "StrongPassword123!" # Replace with a secure password
  db_subnet_group_name   = aws_db_subnet_group.CorporateProject_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.CorporateProject_rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "CorporateProject MySQL DB"
  }
}
resource "aws_s3_bucket" "SB3" {
  bucket = "sb3bucket333"  # Bucket names must be globally unique and lowercase
}

resource "aws_s3_bucket_ownership_controls" "SB4" {
  bucket = aws_s3_bucket.SB3.id

  rule {
    object_ownership ="BucketOwnerPreferred"  # Valid values: BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter
  }
}

resource "aws_s3_bucket_acl" "SB5" {
  depends_on = [aws_s3_bucket_ownership_controls.SB4]
  bucket     = aws_s3_bucket.SB3.id
  acl        = "private"  # Valid ACL values: private, public-read, public-read-write, authenticated-read, etc.
}

resource "aws_s3_bucket_versioning" "SB6" {
  bucket = aws_s3_bucket.SB3.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Name        = "Terraform State Lock Table"
  }
}
