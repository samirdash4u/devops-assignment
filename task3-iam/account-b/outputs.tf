output "roleC_arn" {
  value       = aws_iam_role.roleC.arn
  description = "ARN of Account B roleC."
}

output "trusted_roleB_arn" {
  value       = local.role_b_arn
  description = "The only principal explicitly trusted by roleC."
}
