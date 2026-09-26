# The S3 backend is intentionally configured with placeholders.
# Backend configuration cannot use normal Terraform variables because the
# backend is initialized BEFORE Terraform evaluates variables.
#
# Initialize it with:
# terraform init \
#   -backend-config="bucket=<your-state-bucket>" \
#   -backend-config="key=devops-assignment/terraform.tfstate" \
#   -backend-config="region=ap-south-1" \
#   -backend-config="dynamodb_table=terraform-state-lock" \
#   -backend-config="encrypt=true"

terraform {
  backend "s3" {
    # Values are supplied using -backend-config during terraform init.
    # Keeping the backend block here documents the intended remote backend.
  }
}
