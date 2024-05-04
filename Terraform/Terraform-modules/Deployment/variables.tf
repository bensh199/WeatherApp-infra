variable "app_name" {
  type        = string
  description = "App name to prepend to resources name and tags"
  default     = "Lab4-EKS"
}

variable "aws_region" {
  type        = string
  description = "The aws region to use"
  default     = "il-central-1"
}

variable "aws_availability_zones" {
  type        = list(string)
  default     = ["il-central-1a", "il-central-1b"]
  description = "availability zones to use"
}

variable "vpc_cidr" {
  type        = string
  description = "An CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "ROOT_PATH" {
  description = "Root path for the project"
}

variable "ARGOCD_PASS" {
  description = "will be aquiered by local exec"
  type = string
}

variable "REPO_USERNAME" {
  type = string
}

variable "HELM_REPO_PAT" {
  type = string
}

variable "config_path" {
  type = string
  default = "~/.kube/config"
}

variable "argocd_server_addr" {
  type = string
  default = "argocd.whats-the-weather.com"
}