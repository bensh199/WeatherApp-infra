# Deploy ArgoCD Application
# provider "argocd" {
#   server_addr = "argocd.whats-the-weather.com:443"
#   username    = "admin"
#   password    = "TokOueeVhfEtIi-W"
# }

# resource "argocd_application" "helm" {
#   metadata {
#     name      = "helm-app"
#     namespace = "argocd"
#     labels = {
#       test = "true"
#     }
#   }

#   spec {
#     destination {
#       server    = "https://kubernetes.default.svc"
#       namespace = "default"
#     }
#     source {
#       repo_url        = "https://github.com/bensh199/WeatherApp-Helm.git"
#       path = "WeatherApp"
#       chart           = "WeatherApp"
#       target_revision = "HEAD"
#       helm {
#         release_name = "testing"
#         value_files = ["values.yml"]
#       }
#     }
#   }
# }

# provider "kubectl" {
#   host                   = var.cluster-endpoint
#   cluster_ca_certificate = base64decode(var.cluster-CA)
#   # token                  = data.aws_eks_cluster_auth.main.token
#   load_config_file       = true
#   # config_path = KUBE_CONFIG_PATH
# }

# resource "kubectl_manifest" "test" {
#   wait = true
#   yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: weatherapp
#   namespace: argocd
# spec:
#   project: default

#   source:
#     repoURL: https://github.com/bensh199/WeatherApp-Helm
#     targetRevision: HEAD
#     path: WeatherApp
#   destination: 
#     server: https://kubernetes.default.svc
#     namespace: myapp

#   syncPolicy:
#     syncOptions:
#     - CreateNamespace=true

#     automated:
#       selfHeal: true
#       prune: true
# YAML
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   version    = "6.7.3"
#   namespace  = "argocd"
#   timeout    = "1200"
#   values     = [templatefile("${var.ROOT_PATH}/ArgoCD/values.yaml", {})]
# }

resource "helm_release" "weatherapp" {
  name       = "application"
  repository = "https://${var.REPO_PAT}@github.com/bensh199/WeatherApp-Helm"
  chart      = "${vat.ROOT_PATH}/WeatherApp-Helm/WeatherApp-argocdApp/app"
  version    = "0.1.0"
  namespace = "argocd"
}