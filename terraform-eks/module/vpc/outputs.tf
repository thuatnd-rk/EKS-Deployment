output "eks_public_subnet" {
  value = aws_subnet.eks_public_subnet[*].id
}

output "eks_private_subnet" {
  value = aws_subnet.eks_private_subnet[*].id
}

output "eks_vpc" {
  value = aws_vpc.eks_vpc.id
}