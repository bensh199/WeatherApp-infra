variable "subnet_ids" {
  type = list(string)
}

variable "cluster_name" {
  default = "Lab4-EKS-tf"
  type = string
  description = "Cluster for Lab4-Project"
  nullable = false
}

variable "nodes_subnet_ids" {
  type = list(string)
}