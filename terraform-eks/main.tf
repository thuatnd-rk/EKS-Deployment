module "vpc" {
  source   = "./module/vpc"
  vpc_cidr = var.aws_vpc
}

module "iam" {
  source = "./module/iam"
}


module "eks" {
  source = "./module/eks"
  aws_vpc = module.vpc.eks_vpc
  aws_public_subnet = module.vpc.eks_public_subnet
  aws_private_subnet = module.vpc.eks_private_subnet
  aws_role_cluster = module.iam.eks_role_cluster
  aws_role_nodes = module.iam.eks_role_node
  cluster_AmazonEKSClusterPolicy = module.iam.cluster_AmazonEKSClusterPolicy
  cluster_AmazonEKSBlockStoragePolicy = module.iam.cluster_AmazonEKSBlockStoragePolicy
  cluster_AmazonEKSLoadBalancingPolicy = module.iam.cluster_AmazonEKSLoadBalancingPolicy
  cluster_AmazonEKSNetworkingPolicy = module.iam.cluster_AmazonEKSNetworkingPolicy
  cluster_AmazonEKSVPCResourceController = module.iam.cluster_AmazonEKSVPCResourceController
  eks-AmazonEKSWorkerNodePolicy = module.iam.eks-AmazonEKSWorkerNodePolicy
  eks-AmazonEKS_CNI_Policy = module.iam.eks-AmazonEKS_CNI_Policy
  eks-AmazonEC2ContainerRegistryFullAccess = module.iam.eks-AmazonEC2ContainerRegistryFullAccess
}
