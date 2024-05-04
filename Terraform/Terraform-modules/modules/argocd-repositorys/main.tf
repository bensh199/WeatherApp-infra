provider "argocd" {
  server_addr = "argocd.whats-the-weather.com:443"
  username    = "admin"
  password    = "TokOueeVhfEtIi-W"
}

resource "argocd_repository" "private" {
  repo            = "https://github.com/bensh199/WeatherApp-Helm.git"
  username        = var.repo-username
  password        = var.repo-PAT
  insecure        = true
  type            = "git"
}