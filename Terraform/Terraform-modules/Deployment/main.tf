# terraform {
#   backend "s3" {
#     bucket         = "weatherapp-eks-state-backend"
#     key            = "terraform.tfstate"
#     region         = "il-central-1"
#     dynamodb_table = "WeatherApp-Eks-state-backend"
#   }
# }

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
module "iam-oidc" {
  source              = "../modules/iam-oidc"
  eks_oidc_issuer_url = module.eks.eks_oidc_issuer_url
  depends_on          = [module.network, module.eks]
}
resource "null_resource" "update_kubeconfig" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region} && sleep 30" 
  }
  depends_on = [module.eks]
}
module "eks-albcontroller" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/eks-albcontroller"
  cluster_name = module.eks.cluster_name
  cluster-endpoint = module.eks.cluster_endpoint
  oidc-issuer = module.eks.eks_oidc_issuer_url
  oidc-provider-arn = module.iam-oidc.oidc_arn
  config_path = var.config_path
  # cluster-CA = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZVhEeEdDQVRDYVF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBMU1ETXlNREkzTUROYUZ3MHpOREExTURFeU1ETXlNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURZeEVTeFoxa01GS1ZnWGVBUXJwY0QxZmZOU0VFb2p0dk1GYkFtWTZDaytzdnV3TEdIKzB3MmpmcEkKN3NuQ1JycnovNDU2UXJpcDRVd3VPMXNkWExLSUN2VC9sa0ltQ3E5RDJTbTJsV2s5QjIxTmhybWdSZ0R3SDM1TgpRVTZGYXlyS2Z4QjB5bThlb1RLak44N3NYa1BNOW4zSUpDSVBaOVNtL3Z6WXZyZ2owQWJQcmJ1bnJkMHFzSDEzClVzcFhFcnZ0a1lvQ3dNNHFzVUtIN3hhdUdMZEFMUnovMXhwcDY2MEFEbFNmU1N1ZnI1aE8xN1M2MG83b2IyUlAKcVZ3akk3OVY0TFcrSGo4UHJIRndkQWIvVGJseFVaSHNlUXQ2QjZGN3VvUXdqbDFJKzVHQWxIbkw4SWU0L2tnNwoxNVJ4TEVXNEZqVDJ6cGwxSDNHUVpHRmdzS290QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSb05ZT29NMTdxaHdnbjVtME1XZktRR01tbDhEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2ZKOUxWd2ZGVQo3TFJGb3FOemt4dFU5UXhpdnpoMTR4QnJJODNoZUVJQ1JsUC9weUs5TlNWaCtuMFpTZ0x4dnpxREd5ZWludHp1CjhyVzFYSlRPWFNoS3hzb2l5bjZsSXgxVVVza3RxU255K2ZsU1g5NDh6R0Vaa3JTTkdXd29qM3ZUbWNERVNLdzQKdGtORHA2bDBBSGg1YVBLTklxYnlMZklPdEQwQU5TWTFlREMxUHc2NlErZ2hLT1NGVjloMDNuejVQQWdXRE8rWgpPbFJBZkQ4VUx1ZFJGWThrV1grTGYxUHc2Q0hXV284S1M4bGF4T2IxVktHbTI2QnV0V2h0UjhiNnFYcTV1OWVrCjNnTU1mZVhTRVlkRUNnczhRdUV4ZFdOT3VxclNDYnFxdThOQmprY2EwRFl1ekRiSjZTQTJycVFqY3JKYk5DT1oKZk01QVRicmtTc2VyCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  depends_on = [ null_resource.update_kubeconfig ]
}

module "eks-csi" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/eks-csi"
  cluster_name = module.eks.cluster_name
  oidc_provider_arn = module.iam-oidc.oidc_arn
  depends_on = [ null_resource.update_kubeconfig ]
}

module "external-dns" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/external-dns"
  oidc-arn = module.iam-oidc.oidc_arn
  oidc-issuer = module.eks.eks_oidc_issuer_url
  depends_on = [ null_resource.update_kubeconfig ]
}

module "argocd" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/argocd-deployment"
  ROOT_PATH = var.ROOT_PATH
  cluster-name = module.eks.cluster_name
  depends_on = [ null_resource.update_kubeconfig ]
}

resource "null_resource" "argocd-init-password" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command     = <<-EOT
      TF_VAR_ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d);
      echo $TF_VAR_ARGOCD_PASS | tr -d '%';
      export TF_VAR_ARGOCD_PASS=$TF_VAR_ARGOCD_PASS
    EOT
  }
  depends_on = [ module.argocd ]
}

module "argocd-repositorys" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/argocd-repositorys"
  argo-initial-pass = var.ARGOCD_PASS
  repo-username = var.REPO_USERNAME
  repo-PAT = var.HELM_REPO_PAT
  depends_on = [ null_resource.argocd-init-password ]
}

module "deploy-weatherapp" {
  source = "../../../../WeatherApp-infra/Terraform/Terraform-modules/modules/argo-weather-app"
  REPO_PAT = var.HELM_REPO_PAT
  ROOT_PATH = var.ROOT_PATH
  # cluster-CA = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZVhEeEdDQVRDYVF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBMU1ETXlNREkzTUROYUZ3MHpOREExTURFeU1ETXlNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURZeEVTeFoxa01GS1ZnWGVBUXJwY0QxZmZOU0VFb2p0dk1GYkFtWTZDaytzdnV3TEdIKzB3MmpmcEkKN3NuQ1JycnovNDU2UXJpcDRVd3VPMXNkWExLSUN2VC9sa0ltQ3E5RDJTbTJsV2s5QjIxTmhybWdSZ0R3SDM1TgpRVTZGYXlyS2Z4QjB5bThlb1RLak44N3NYa1BNOW4zSUpDSVBaOVNtL3Z6WXZyZ2owQWJQcmJ1bnJkMHFzSDEzClVzcFhFcnZ0a1lvQ3dNNHFzVUtIN3hhdUdMZEFMUnovMXhwcDY2MEFEbFNmU1N1ZnI1aE8xN1M2MG83b2IyUlAKcVZ3akk3OVY0TFcrSGo4UHJIRndkQWIvVGJseFVaSHNlUXQ2QjZGN3VvUXdqbDFJKzVHQWxIbkw4SWU0L2tnNwoxNVJ4TEVXNEZqVDJ6cGwxSDNHUVpHRmdzS290QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSb05ZT29NMTdxaHdnbjVtME1XZktRR01tbDhEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2ZKOUxWd2ZGVQo3TFJGb3FOemt4dFU5UXhpdnpoMTR4QnJJODNoZUVJQ1JsUC9weUs5TlNWaCtuMFpTZ0x4dnpxREd5ZWludHp1CjhyVzFYSlRPWFNoS3hzb2l5bjZsSXgxVVVza3RxU255K2ZsU1g5NDh6R0Vaa3JTTkdXd29qM3ZUbWNERVNLdzQKdGtORHA2bDBBSGg1YVBLTklxYnlMZklPdEQwQU5TWTFlREMxUHc2NlErZ2hLT1NGVjloMDNuejVQQWdXRE8rWgpPbFJBZkQ4VUx1ZFJGWThrV1grTGYxUHc2Q0hXV284S1M4bGF4T2IxVktHbTI2QnV0V2h0UjhiNnFYcTV1OWVrCjNnTU1mZVhTRVlkRUNnczhRdUV4ZFdOT3VxclNDYnFxdThOQmprY2EwRFl1ekRiSjZTQTJycVFqY3JKYk5DT1oKZk01QVRicmtTc2VyCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  # cluster-endpoint = module.eks.cluster_endpoint
  depends_on = [ module.argocd-repositorys ]
}

# module "roles" {
#   source = "../modules/roles"
#   oidc_provider_arn = module.iam-oidc.oidc_arn
# }

# resource "null_resource" "ArgoCD-Init-Script" {
#   provisioner "local-exec" {
#     command = "sh ${var.ROOT_PATH}/WeatherApp-infra/ArgoCD/ArgoCD-Init.sh -a ${data.aws_caller_identity.current.account_id} -r ${var.aws_region} -c ${module.eks.cluster_name} -p ${var.ROOT_PATH}; export CLUSTER_NAME=${module.eks.cluster_name} ACCOUNT_ID=${data.aws_caller_identity.current.account_id}"
#   }
#   depends_on = [module.network, module.eks, module.iam-oidc]
# }