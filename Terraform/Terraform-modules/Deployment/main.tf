terraform {
  backend "s3" {
    bucket         = "weatherapp-eks-state-backend"
    key            = "terraform.tfstate"
    region         = "il-central-1"
    dynamodb_table = "WeatherApp-Eks-state-backend"
  }
}

# Set up the network module
module "network" {
  source                 = "../modules/network"
  vpc_cidr               = var.vpc_cidr
  aws_availability_zones = var.aws_availability_zones
}

# Set up the EKS module
module "eks" {
  source           = "../modules/eks"
  subnet_ids       = module.network.subnet_ids
  nodes_subnet_ids = module.network.nodes_subnet_ids
  depends_on       = [module.network]
}

# Set up the IAM OIDC module
module "iam" {
  source              = "../modules/iam-oidc"
  eks_oidc_issuer_url = module.eks.eks_oidc_issuer_url
  depends_on          = [module.network]
}

resource "null_resource" "ArgoCD-Init-Script" {
  provisioner "local-exec" {
    command = "sh ${var.ROOT_PATH}/WeatherApp-infra/ArgoCD/ArgoCD-Init.sh -a ${data.aws_caller_identity.current.account_id} -r ${var.aws_region} -c ${module.eks.cluster_name} -p ${var.ROOT_PATH}"
  }
  depends_on = [module.network, module.eks, module.iam]
}