data "aws_iam_policy_document" "ec2_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "iam:ListUsers",
      "iam:GetGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys"
    ]
    resources = [
      "arn:aws:iam::*:user/*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ec2" {
  role   = var.ec2_role_id
  policy = data.aws_iam_policy_document.ec2_policy.json
}
