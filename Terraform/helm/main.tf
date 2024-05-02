provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "replicaCount"
    value = "2"  #default is 2
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }

  depends_on = [module.eks]
}

resource "helm_release" "argocd" {
  depends_on = [ module.eks-external-dns ]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace = var.kubernetes_argocd_namespace
  create_namespace = true
  version    = "6.7.18"  # Replace with the desired version of ArgoCD
  timeout    = "1200"
  values     = [templatefile("modules/eks/argocd/values.yaml", {})]

  # You can add more `set` blocks to customize ArgoCD configuration
}