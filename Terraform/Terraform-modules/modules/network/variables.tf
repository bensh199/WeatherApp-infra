variable "vpc_cidr" {
  type        = string
  description = "An CIDR for the VPC"
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "AWS AZs to use"
}