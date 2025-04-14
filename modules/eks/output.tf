output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_node_group_name" {
  value = aws_eks_node_group.eks_nodes.node_group_name
}

