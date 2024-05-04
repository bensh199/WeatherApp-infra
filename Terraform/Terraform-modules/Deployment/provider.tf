provider "aws" {
  region = "il-central-1"
}

terraform {
  backend "s3" {
    bucket         = "weatherapp-eks-state-backend"
    key            = "terraform.tfstate"
    region         = "il-central-1"
    dynamodb_table = "WeatherApp-Eks-state-backend"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}