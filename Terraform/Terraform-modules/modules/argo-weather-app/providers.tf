terraform {
  required_providers {
    argocd = {
      source = "oboukili/argocd"
      version = "6.1.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
