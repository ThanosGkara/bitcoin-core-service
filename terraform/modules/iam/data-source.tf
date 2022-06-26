# Get the current aws account (caller id) to be used
data aws_caller_identity current {}

# IAM Policy document that allows assume role for users respecting the conditions
data aws_iam_policy_document role_allow_assume {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

# IAM policy that allows entities to assume the IAM role
data aws_iam_policy_document assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.role.name}",
    ]
  }
}