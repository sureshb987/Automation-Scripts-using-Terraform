output "cluster_id" {
  value = aws_eks_cluster.CorporateProject.id
}

output "node_group_id" {
  value = aws_eks_node_group.CorporateProject.id
}
