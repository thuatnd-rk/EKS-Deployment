locals {
  name = "ndthuat"
  account_id = "187091248012"
  user = "ndthuat.intern"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.name}-eks-cluster"
  version  = "1.31"
  role_arn = var.aws_role_cluster

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.eks_sg_cluster.id]

    subnet_ids = flatten([
      var.aws_public_subnet,
      var.aws_private_subnet,
    ])
  }


  # kubernetes_network_config {
  #   elastic_load_balancing {
  #     enabled = true
  #   }
  # }

  kubernetes_network_config {
    service_ipv4_cidr = null
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  #
  bootstrap_self_managed_addons = true
  # Auto create and delete nodes 
  # compute_config {
  #   enabled       = true
  #   node_pools    = ["general-purpose"]
  #   node_role_arn = var.aws_role_nodes
  # }



  # storage_config {
  #   block_storage {
  #     enabled = true
  #   }
  # }


  depends_on = [
    var.cluster_AmazonEKSClusterPolicy,
    var.cluster_AmazonEKSBlockStoragePolicy,
    var.cluster_AmazonEKSLoadBalancingPolicy,
    var.cluster_AmazonEKSNetworkingPolicy,
    var.cluster_AmazonEKSVPCResourceController,
  ]
}


resource "aws_security_group" "eks_sg_cluster" {
  name        = "${local.name}eks-sg-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.aws_vpc
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg-eks"
  }
}


resource "aws_eks_node_group" "eks_nodes_private" {
  cluster_name = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.name}-eks-ng-private"
  node_role_arn   = var.aws_role_nodes
  subnet_ids      = var.aws_private_subnet
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    


  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t2.small"]


  remote_access {
    ec2_ssh_key = "ndthuat-us-east-1"
  }


  scaling_config {
    desired_size = 3
    min_size     = 2
    max_size     = 4
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  depends_on = [
    var.eks-AmazonEKSWorkerNodePolicy,
    var.eks-AmazonEKS_CNI_Policy,
    var.eks-AmazonEC2ContainerRegistryFullAccess,
  ]
  tags = {
    "Name"                                            = "${local.name}-Private-Node-Group"
    "kubernetes.io/cluster/${local.name}-eks-cluster" = "shared"
  }

} 

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks-auth.token
}

data "aws_eks_cluster_auth" "eks-auth" {
  name = aws_eks_cluster.eks_cluster.name
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOT
    - rolearn: ${var.aws_role_nodes}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::${local.account_id}:user/${local.user}
      username: ${local.user}
      groups:
        - system:masters
    EOT
  }
}