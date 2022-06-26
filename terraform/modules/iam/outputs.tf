
output "aws_iam_role_arn" {
  description = "The IAM role ARN"
  value       = aws_iam_role.role.arn
}

output "aws_iam_group_arn" {
  description = "The IAM group ARN"
  value       = aws_iam_group.no_permissions_group.arn
}

output "aws_iam_user_arn" {
  description = "The IAM user ARN"
  value       = aws_iam_user.user.arn
}
