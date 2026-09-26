#!/usr/bin/env bash
set -euo pipefail

# One-time bootstrap helper.
# Terraform must first use local state because the remote S3 bucket and
# DynamoDB lock table do not exist yet.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <globally-unique-state-bucket-name>"
  exit 1
fi

BUCKET_NAME="$1"
REGION="ap-south-1"
LOCK_TABLE="terraform-state-lock"

echo "Creating the S3 state bucket and DynamoDB lock table using local state..."
terraform init
terraform apply \
  -var="terraform_state_bucket=${BUCKET_NAME}" \
  -var="aws_region=${REGION}" \
  -auto-approve

echo "Migrating Terraform state to S3 and enabling DynamoDB locking..."
terraform init -reconfigure \
  -backend-config="bucket=${BUCKET_NAME}" \
  -backend-config="key=devops-assignment/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="dynamodb_table=${LOCK_TABLE}" \
  -backend-config="encrypt=true"

echo "Remote backend configured successfully."
