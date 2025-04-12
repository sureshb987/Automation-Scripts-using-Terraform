
variable "key_name" {
  description = "The SSH key name for EC2 instances"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Production environment"
  type        = string
}
