variable "aws_region" {
  description = "AWS region for the Terraform state-locking infrastructure."
  type        = string
  default     = "ap-south-1"
}

variable "terraform_state_bucket" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "state_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
  default     = "terraform-state-lock"
}
