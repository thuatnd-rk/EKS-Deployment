output "eks_role_cluster" {
  value = aws_iam_role.eks_role_cluster.arn
}

output "eks_role_node" {
  value = aws_iam_role.eks_roles_nodes.arn
}

output "cluster_AmazonEKSClusterPolicy" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy.policy_arn
}

output "cluster_AmazonEKSVPCResourceController" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController.policy_arn
}


output "cluster_AmazonEKSBlockStoragePolicy" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy.policy_arn
}

output "cluster_AmazonEKSLoadBalancingPolicy" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy.policy_arn
}

output "cluster_AmazonEKSNetworkingPolicy" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy.policy_arn
}

output "eks-AmazonEKSWorkerNodePolicy" {
  value = aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy.policy_arn
}

output "eks-AmazonEKS_CNI_Policy" {
  value = aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy.policy_arn
}

output "eks-AmazonEC2ContainerRegistryFullAccess" {
  value = aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryFullAccess.policy_arn
}
