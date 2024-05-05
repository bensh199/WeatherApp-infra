variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cluster_version" {
  type = string
  default = "1.23"
}

variable "cluster_name" {
  default = "Lab4-EKS-tf"
  type = string
  description = "Cluster for Lab4-Project"
  nullable = false
}

variable "private_subnets" {
  type = list(string)
}