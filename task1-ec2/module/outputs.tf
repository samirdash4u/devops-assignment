# Map: instance name -> EC2 instance ID.
output "instance_ids" {
  description = "EC2 instance IDs keyed by instance name."
  value = merge(
    { for name, instance in aws_instance.standard : name => instance.id },
    { (local.protected_instance_name) = aws_instance.protected.id }
  )
}

# Map: instance name -> private IP address.
output "private_ips" {
  description = "Private IP addresses keyed by instance name."
  value = merge(
    { for name, instance in aws_instance.standard : name => instance.private_ip },
    { (local.protected_instance_name) = aws_instance.protected.private_ip }
  )
}
