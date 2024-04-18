# Output the IDs of all subnets
output "subnet_ids" {
  value = concat(
    aws_subnet.Private-Lab4-il-central-1a[*].id,
    aws_subnet.Private-Lab4-il-central-1b[*].id,
    aws_subnet.Public-Lab4-il-central-1a[*].id,
    aws_subnet.Public-Lab4-il-central-1b[*].id
  )
}

# Output the IDs of private subnets for node groups
output "nodes_subnet_ids" {
  value = concat(
    aws_subnet.Private-Lab4-il-central-1a[*].id,
    aws_subnet.Private-Lab4-il-central-1b[*].id
  )
}