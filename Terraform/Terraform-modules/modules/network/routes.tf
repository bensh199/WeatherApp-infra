# Create a public route table and associate it with the main VPC
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Create a private route table and associate it with the main VPC
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private_route_table"
  }
}

# Associate the private route table with the private subnet in availability zone 'a'
resource "aws_route_table_association" "Private-Lab4-il-central-1a" {
  subnet_id      = aws_subnet.Private-Lab4-il-central-1a.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate the private route table with the private subnet in availability zone 'b'
resource "aws_route_table_association" "Private-Lab4-il-central-1b" {
  subnet_id      = aws_subnet.Private-Lab4-il-central-1b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate the public route table with the public subnet in availability zone 'a'
resource "aws_route_table_association" "Public-Lab4-il-central-1a" {
  subnet_id      = aws_subnet.Public-Lab4-il-central-1a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the public route table with the public subnet in availability zone 'b'
resource "aws_route_table_association" "Public-Lab4-il-central-1b" {
  subnet_id      = aws_subnet.Public-Lab4-il-central-1b.id
  route_table_id = aws_route_table.public_route_table.id
}
