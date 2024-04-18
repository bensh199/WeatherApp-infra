# Define a TLS certificate data source for EKS
data "tls_certificate" "eks" {
  url = var.eks_oidc_issuer_url
}

# Create an IAM OpenID Connect provider for EKS
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.eks_oidc_issuer_url
}
