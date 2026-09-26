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
  role_c_arn = "arn:aws:iam::${var.account_b_id}:role/roleC"
}

# ---------------------------------------------------------------------------
# Users and groups
# ---------------------------------------------------------------------------

resource "aws_iam_user" "group1" {
  for_each = var.group1_users
  name     = each.value

  tags = {
    ManagedBy = "terraform"
    Group     = "group1"
  }
}

resource "aws_iam_user" "group2" {
  for_each = var.group2_users
  name     = each.value

  tags = {
    ManagedBy = "terraform"
    Group     = "group2"
  }
}

resource "aws_iam_group" "group1" {
  name = "group1"
}

resource "aws_iam_group" "group2" {
  name = "group2"
}

resource "aws_iam_group_membership" "group1" {
  name  = "group1-membership"
  group = aws_iam_group.group1.name
  users = [for user in aws_iam_user.group1 : user.name]
}

resource "aws_iam_group_membership" "group2" {
  name  = "group2-membership"
  group = aws_iam_group.group2.name
  users = [for user in aws_iam_user.group2 : user.name]
}

# group1 is intentionally not given a console login profile.
# In production, its users should preferably receive short-lived credentials
# through federation/workload identity rather than permanent access keys.

# ---------------------------------------------------------------------------
# roleA - administrative access except IAM
# ---------------------------------------------------------------------------

resource "aws_iam_role" "roleA" {
  name = "roleA"

  # Account A can use this role. The permission policy below deliberately
  # excludes IAM actions.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_a_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    ManagedBy = "terraform"
  }
}

# This is a custom policy rather than AdministratorAccess. NotAction excludes
# every IAM API action while allowing the other AWS service APIs.
resource "aws_iam_role_policy" "roleA_admin_without_iam" {
  name = "roleA-admin-without-iam"
  role = aws_iam_role.roleA.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      NotAction = "iam:*"
      Resource = "*"
    }]
  })
}

# ---------------------------------------------------------------------------
# roleB - can ONLY assume roleC in Account B
# ---------------------------------------------------------------------------

resource "aws_iam_role" "roleB" {
  name = "roleB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_a_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "roleB_assume_roleC" {
  name = "roleB-assume-roleC"
  role = aws_iam_role.roleB.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = local.role_c_arn
    }]
  })
}
