variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "Devops project"
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "sg_ids" {
  description = "List of security group IDs"
  type        = list(string)
}
