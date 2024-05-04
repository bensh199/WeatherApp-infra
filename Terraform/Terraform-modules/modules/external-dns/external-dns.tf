resource "aws_iam_policy" "external_dns_policy" {
  name        = "external-dns-route53-policy"
  description = "Policy for ExternalDNS to manage Route 53 resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
        Resource = ["*"]
      }
    ]
  })
}

module "eks-external-dns" {
    source  = "lablabs/eks-external-dns/aws"
    version = "1.2.0"
    helm_chart_version = "7.2.1"
    cluster_identity_oidc_issuer =  var.oidc-issuer
    cluster_identity_oidc_issuer_arn = var.oidc-arn
    policy_allowed_zone_ids = [
        var.route_53_zone_id  # zone id of your hosted zone
    ]
    settings = {
    "policy" = "sync" # syncs DNS records with ingress and services currently on the cluster.
  }
  irsa_additional_policies = {
      external_dns_policy = aws_iam_policy.external_dns_policy.arn
  }
}