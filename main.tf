provider "aws" {
  region = "eu-central-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Allocate Elastic IP for NAT gateway
resource "aws_eip" "my_eip" {
  vpc = true
}

# Create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with NAT gateway
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.my_nat_gateway.id
}

# Create EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "@@@ YourEksClusterName @@@"
  role_arn = aws_iam_role.eks_role.arn
  # Add more configurations as needed
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_role" {
  name               = "@@@ YourEksRoleName @@@"
  assume_role_policy = "@@@ YourEksAssumeRolePolicy @@@"
}

# Attach policies to IAM role for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "@@@ YourPolicyARN @@@"
}

# Create load balancer
resource "aws_lb" "my_lb" {
  name               = "@@@ YourLoadBalancerName @@@"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id]
}

# Define security group for load balancer
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  # Define your security group rules as needed
}
