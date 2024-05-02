# module "eks-external-dns" {
#     source  = "lablabs/eks-external-dns/aws"
#     version = "1.2.0"
#     helm_chart_version = "7.2.1"
#     cluster_identity_oidc_issuer =  aws_eks_cluster.Lab4-EKS.identity[0].oidc[0].issuer
#     cluster_identity_oidc_issuer_arn = var.oidc-arn
#     policy_allowed_zone_ids = [
#         var.route_53_zone_id  # zone id of your hosted zone
#     ]
#     settings = {
#     "policy" = "sync" # syncs DNS records with ingress and services currently on the cluster.
#   }
#   irsa_additional_policies = {
#       external_dns_policy = aws_iam_policy.external_dns_policy.arn
#   }
#   depends_on = [module.eks, helm_release.aws_load_balancer_controller]
# }