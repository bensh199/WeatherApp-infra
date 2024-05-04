variable "enable_aws_ebs_csi_driver_role" {
  description = "Determines whether to install EBS CSI Driver IRSA"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role"
  type        = string
  default     = "ebs-csi"
}