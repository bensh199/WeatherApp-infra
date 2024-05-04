resource "argocd_repository" "private" {
  repo            = "https://github.com/bensh199/WeatherApp-Helm.git"
  username        = var.repo-username
  password        = var.repo-PAT
  insecure        = true
  type            = "git"
}