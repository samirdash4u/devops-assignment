output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket created for Terraform remote state."
}

output "state_lock_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDB table used for Terraform state locking."
}
