# Output the ARN of the test OIDC role
output "test_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}