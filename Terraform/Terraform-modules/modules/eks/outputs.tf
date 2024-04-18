# Output the OIDC issuer URL of the EKS cluster
output "eks_oidc_issuer_url" {
  value = aws_eks_cluster.Lab4-EKS.identity[0].oidc[0].issuer
}