output "cluster_id" {
  value = aws_eks_cluster.CorporateProject.id
}

output "node_group_id" {
  value = aws_eks_node_group.CorporateProject.id
}

output "vpc_id" {
  value = aws_vpc.CorporateProject_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.CorporateProject_subnet[*].id
}
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.CorporateProject_mysql.endpoint
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.CorporateProject_mysql.username
}

output "rds_db_name" {
  description = "RDS database name"
  value       = aws_db_instance.CorporateProject_mysql.name
}
