# Create the main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Lab4-VPC"
  }
}

# Create an internet gateway and attach it to the main VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Allocate an Elastic IP (EIP) for NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat"
  }
}

# Create a NAT gateway in a public subnet for outgoing internet traffic
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.Public-Lab4-il-central-1a.id

  tags = {
    domain = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}