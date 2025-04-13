output "vpc_id" {
  value = aws_vpc.CorporateProject_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.CorporateProject_subnet[*].id
}
