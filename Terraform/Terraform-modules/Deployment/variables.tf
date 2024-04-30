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

data "aws_caller_identity" "current" {}

variable "ACCOUNT_ID" {
  description = "AWS Account ID"
  default     = data.aws_caller_identity.current.account_id
}