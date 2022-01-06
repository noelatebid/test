####
# Github Actions access

resource "aws_iam_user" "githubactions" {
  name = "githubactions-${var.environment}"
  path = "/system/"
  tags = local.default_tags
}

resource "aws_iam_access_key" "githubactions" {
  user = aws_iam_user.githubactions.name
}


data "aws_iam_policy_document" "eks_policy" {
  statement {
    effect = "Allow"

    actions = [
      "eks:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "eks_policy" {
  name        = "AmazonEKSAdminPolicy-${var.environment}"
  description = "A policy for administration of EKS Clusters and their resources (Terraform)"

  policy = data.aws_iam_policy_document.eks_policy.json
}

resource "aws_iam_user_policy_attachment" "eks" {
  user       = aws_iam_user.githubactions.name
  policy_arn = aws_iam_policy.eks_policy.arn
}


resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.githubactions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


####
# App access

resource "aws_iam_user" "app_access" {
  name = "app_aws_access-${var.environment}"
  path = "/system/"
  tags = local.default_tags
}

resource "aws_iam_access_key" "app_access" {
  user = aws_iam_user.app_access.name
}

resource "aws_iam_user_policy_attachment" "app_aws_access-s3-logs-rw" {
  user       = aws_iam_user.app_access.name
  policy_arn = aws_iam_policy.app-s3-rw.arn
}
