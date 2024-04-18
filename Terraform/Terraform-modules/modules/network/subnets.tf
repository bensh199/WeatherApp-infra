# Create a private subnet in availability zone 'a'
resource "aws_subnet" "Private-Lab4-il-central-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "il-central-1a"

  tags = {
    "Name"                              = "Private-Lab4-il-central-1a"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/Lab4-EKS-tf" = "owned"
  }
}

# Create a private subnet in availability zone 'b'
resource "aws_subnet" "Private-Lab4-il-central-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "il-central-1b"

  tags = {
    "Name"                              = "Private-Lab4-il-central-1b"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/Lab4-EKS-tf" = "owned"
  }
}

# Create a public subnet in availability zone 'a'
resource "aws_subnet" "Public-Lab4-il-central-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "il-central-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                              = "Public-Lab4-il-central-1a"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/Lab4-EKS-tf" = "owned"
  }
}

# Create a public subnet in availability zone 'b'
resource "aws_subnet" "Public-Lab4-il-central-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.48.0/20"
  availability_zone       = "il-central-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                              = "Public-Lab4-il-central-1b"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/Lab4-EKS-tf" = "owned"
  }
}