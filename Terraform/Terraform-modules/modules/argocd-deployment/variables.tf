variable "cluster-name" {
  type    = string
}

variable "env" {
  default = "argocd"
}

variable "ROOT_PATH" {
  description = "Root path for the project"
}