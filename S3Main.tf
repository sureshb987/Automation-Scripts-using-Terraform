provider "aws" {
  region     = "ap-south-1"
  access_key = ""  # Replace with your AWS access key
  secret_key = ""  # Replace with your AWS secret key
}

resource "aws_s3_bucket" "SB3" {
  bucket = "sb3bucket33"  # Bucket names must be globally unique and lowercase
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
