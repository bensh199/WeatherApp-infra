resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "${var.env}"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.7.3"
  namespace  = "argocd"
  timeout    = "1200"
  values     = [templatefile("${var.ROOT_PATH}/ArgoCD/values.yaml", {})]
}