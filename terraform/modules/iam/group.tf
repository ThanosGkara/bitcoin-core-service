# IAM user group with no permissions
resource aws_iam_group no_permissions_group {
  name = "${var.stack}-no-permissions-group"
}

# Bind assume_role_policy policy to the IAM group.
resource aws_iam_group_policy no_permissions_group_group_policy {
  name  = "${var.stack}-group-policy" # prefix appened to prevent random naming
  group = aws_iam_group.no_permissions_group.name

  policy = data.aws_iam_policy_document.assume_role_policy.json
}