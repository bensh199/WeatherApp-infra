# Output the ARN of the test OIDC role
output "test_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}

output "oidc_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}