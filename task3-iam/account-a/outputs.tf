output "roleA_arn" {
  value       = aws_iam_role.roleA.arn
  description = "ARN of Account A roleA."
}

output "roleB_arn" {
  value       = aws_iam_role.roleB.arn
  description = "ARN of Account A roleB. This exact ARN is trusted by roleC."
}

output "group1_users" {
  value       = [for user in aws_iam_user.group1 : user.name]
  description = "Users in group1."
}

output "group2_users" {
  value       = [for user in aws_iam_user.group2 : user.name]
  description = "Users in group2."
}
