variable "account_a_id" {
  description = "AWS account ID containing roleB."
  type        = string
  default     = "000000000000"
}

variable "account_b_id" {
  description = "AWS account ID containing roleC."
  type        = string
  default     = "111111111111"
}

variable "aws_region" {
  description = "AWS region used by this Terraform configuration."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "The single S3 bucket roleC is allowed to access."
  type        = string
  default     = "replace-with-your-specific-bucket"
}
