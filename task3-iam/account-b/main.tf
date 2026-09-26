terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  role_b_arn = "arn:aws:iam::${var.account_a_id}:role/roleB"
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

# roleC is intentionally trusted by the exact roleB ARN, not by the whole
# Account A. This is the important cross-account least-privilege boundary.
resource "aws_iam_role" "roleC" {
  name = "roleC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowOnlyRoleBFromAccountA"
      Effect = "Allow"
      Principal = {
        AWS = local.role_b_arn
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    ManagedBy = "terraform"
  }
}

# Full access to ONE named bucket. Bucket-level actions use the bucket ARN;
# object-level actions use bucket-arn/*.
resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id

  # "Full access to one bucket" is implemented as s3:* against the bucket
  # ARN and all objects below it. The policy cannot access another bucket.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "FullAccessToNamedBucket"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          local.bucket_arn,
          "${local.bucket_arn}/*"
        ]
      }
    ]
  })
}
