# Output the OIDC issuer URL of the EKS cluster
# output "eks_oidc_issuer_url" {
#   value = aws_eks_cluster.Lab4-EKS.identity[0].oidc[0].issuer
# }

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}