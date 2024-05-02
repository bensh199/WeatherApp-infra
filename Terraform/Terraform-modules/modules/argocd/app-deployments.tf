# Deploy ArgoCD Application

module "argocd_application" {
  source  = "project-octal/argocd-application/kubernetes"
  version = "~> 2.0.0"

  argocd_namespace    = "argocd"
  destination_server  = "https://kubernetes.default.svc"
  project             = "default"  # module.project.name
  name                = "hailyeah"
  namespace           = "default"
  repo_url            = "https://github.com/Gilibee-goode/Hailyeah-ArgoCD.git"
  path                = "Helm"
  chart               = ""
  target_revision     = "HEAD"
#   helm_parameters =  [  # another option to update the image that Argo uses
#     {
#         name: "weatherAppImage.tag"
#         value: var.app_image
#         force_string: true
#     }

#   ]
#   helm_values         = {
#       helm_values = "go-here"
#   }
  automated_self_heal = true
  automated_prune     = true
#   labels              = {
#       custom = "lables-to-apply"
#   }
}