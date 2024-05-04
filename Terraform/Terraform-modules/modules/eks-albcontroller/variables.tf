variable "cluster_name" {
  type = string
}

variable "aws_load_balancer_controller_name" {
  type = string
  default = "aws-load-balancer-controller"
}

variable "aws_load_balancer_controller_namespace" {
  type = string
  default = "kube-system"
}

variable "cluster-endpoint" {
  type = string
}

variable "oidc-issuer" {
  type= string
}

variable "oidc-provider-arn" {
  type = string
}

# variable "cluster-CA" {
#   type = string
# }

variable "config_path" {
  type = string
}