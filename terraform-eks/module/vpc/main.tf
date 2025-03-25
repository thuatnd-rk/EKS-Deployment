data "aws_availability_zones" "aws_az" {
  state = "available"
}

locals {
  Name = "ndthuat"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "${local.Name}-VPC"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "eks_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 3, count.index)
  availability_zone       = element(data.aws_availability_zones.aws_az.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                      = "${local.Name}-public-subnet-${count.index}"
    "kubernetes.io/cluster/ndthuat-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }
}

resource "aws_subnet" "eks_private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 3, count.index + length(data.aws_availability_zones.aws_az.names))
  availability_zone       = element(data.aws_availability_zones.aws_az.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name                                      = "${local.Name}-private-subnet-${count.index}"
    "kubernetes.io/cluster/ndthuat-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${local.Name}-igw"
  }
}

resource "aws_eip" "eks_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_natgw" {
  allocation_id = aws_eip.eks_eip.id
  subnet_id     = element(aws_subnet.eks_public_subnet[*].id, 1)
  depends_on    = [aws_internet_gateway.eks_igw]
}

resource "aws_route_table" "eks_public_rtb" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}

resource "aws_route_table" "eks_private_rtb" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_natgw.id
  }

}

resource "aws_route_table_association" "eks_public_rtb_ass" {
  count          = length(aws_subnet.eks_public_subnet[*].id)
  route_table_id = aws_route_table.eks_public_rtb.id
  subnet_id      = element(aws_subnet.eks_public_subnet[*].id, count.index)
}

resource "aws_route_table_association" "eks_private_rtb_ass" {
  count          = length(aws_subnet.eks_private_subnet[*].id)
  route_table_id = aws_route_table.eks_private_rtb.id
  subnet_id      = element(aws_subnet.eks_private_subnet[*].id, count.index)
}



