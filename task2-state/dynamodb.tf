# DynamoDB provides the state lock requested by the assignment.
# Terraform uses the LockID key to coordinate concurrent operations.
resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.state_lock_table_name
    Environment = "shared"
    Owner       = "devops"
  }
}
