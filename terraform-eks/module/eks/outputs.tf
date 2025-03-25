output "name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_status" {
  value = aws_eks_cluster.eks_cluster.status
}