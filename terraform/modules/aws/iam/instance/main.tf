locals {
  name = "${var.namespace}-${var.stage}-${var.name}"
}


resource "aws_iam_instance_profile" "profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "${local.name}-role"
  path = var.path

  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy" "policy" {
  name   = "${local.name}-policy"
  policy = var.policy
  role   = aws_iam_role.role.id
}
