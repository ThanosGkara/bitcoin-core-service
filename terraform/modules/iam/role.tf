# IAM role and assume policy 
resource aws_iam_role role {

  name = "${var.stack}"

  # A policy to assume this role
  assume_role_policy = data.aws_iam_policy_document.role_allow_assume.json

  tags = {
    env         = var.env
    owner       = var.owner
  }
}