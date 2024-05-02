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

# variable "oidc-arn" {
#   type = string
# }

# variable "route_53_zone_id" {
#   description = "route53 zone id"
#   type = string
#   default = "whats-the-weather.com"
# }