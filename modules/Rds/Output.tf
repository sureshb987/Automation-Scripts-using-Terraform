output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.corporateproject_mysql.endpoint
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.corporateproject_mysql.username
}

output "rds_db_name" {
  description = "RDS database name"
  value       = aws_db_instance.corporateproject_mysql.db_name
}
