
resource "aws_s3_bucket" "app-s3" {
  bucket = local.s3_bucket_name

  versioning {
    enabled = true
  }
}

resource "aws_iam_policy" "app-s3-rw" {
  name        = "app-s3-${var.environment}-rw"
  path        = "/"
  description = "Policy that allows Read+Write access to TiLT bucket (Terraform)"
  // @TODO - we need to add cloudfront here, and this policy will change
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FullAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

