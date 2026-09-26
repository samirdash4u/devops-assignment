output "instance_ids" {
  description = "EC2 instance IDs keyed by instance name."
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Private IP addresses keyed by instance name."
  value       = module.ec2.private_ips
}
