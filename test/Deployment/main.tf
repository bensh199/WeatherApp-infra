module "argocd-repositorys" {
  source = "../modules/test-argocd-repos"
  argo-initial-pass = var.ARGOCD_PASS
  repo-username = var.REPO_USERNAME
  repo-PAT = var.REPO_PAT

  # providers = {
  #   argocd = oboukili/argocd
  # }
}