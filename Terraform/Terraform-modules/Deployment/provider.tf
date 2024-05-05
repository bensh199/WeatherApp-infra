provider "aws" {
  region = "il-central-1"
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

provider "argocd" {
  server_addr = "argocd.whats-the-weather.com:443"
  username    = "admin"
  password    = var.ARGOCD_PASS
}

provider "kubernetes" {
  config_path    = var.config_path
}

terraform {
  backend "s3" {
    bucket         = "weatherapp-eks-state-backend"
    key            = "terraform.tfstate"
    region         = "il-central-1"
    dynamodb_table = "WeatherApp-Eks-state-backend"
  }
  required_providers {
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = ">= 1.14.0"
    # }
    argocd = {
      source = "oboukili/argocd"
      version = "6.1.1"
    }
    # kubernetes = {
    #   source = "hashicorp/kubernetes"
    #   version = "2.29.0"
    # }
  }
}