variable "account_a_id" {
  description = "AWS account ID for Account A."
  type        = string
  default     = "000000000000"
}

variable "account_b_id" {
  description = "AWS account ID for Account B."
  type        = string
  default     = "111111111111"
}

variable "aws_region" {
  description = "AWS region used by this Terraform configuration."
  type        = string
  default     = "ap-south-1"
}

variable "group1_users" {
  description = "Users who are members of the CLI/programmatic-only group."
  type        = set(string)
  default     = ["engine", "ci"]
}

variable "group2_users" {
  description = "Users who are members of the console + CLI group."
  type        = set(string)
  default     = ["alice", "bob"]
}
