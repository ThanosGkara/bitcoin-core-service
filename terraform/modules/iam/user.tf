# Create a user
resource aws_iam_user user {
  name = "${var.stack}"
}

# Create a group membership with no permissions
resource aws_iam_group_membership no_permissions_group_membership {
  name = "${var.stack}-no-perms-group-membership"

  users = [
    aws_iam_user.user.name
  ]

  group = aws_iam_group.no_permissions_group.name
}
