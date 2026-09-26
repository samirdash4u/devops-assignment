# Use the latest Amazon Linux 2023 AMI for the selected region.
# The assignment does not require a specific operating system, so using a
# public AWS-maintained AMI avoids hard-coding an AMI ID that changes by region.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
  }

  # Keep the protected instance name in one place so it is obvious which
  # instance has the accidental-deletion guard.
  protected_instance_name = "monitoring-01"

  # All other instances are still driven by the exact same input map.
  unprotected_instances = {
    for name, config in var.instances : name => config
    if name != local.protected_instance_name
  }
}

# Four normal instances are created with one resource block and for_each.
resource "aws_instance" "standard" {
  for_each = local.unprotected_instances

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = each.value.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = contains(["io1", "io2"], each.value.root_volume_type) ? each.value.root_volume_iops : null
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = each.key
  })
}

# Terraform lifecycle meta-arguments such as prevent_destroy cannot depend
# on each.value. We therefore create the one protected member from the same
# input map, but keep it as a separate resource so ONLY this instance gets
# prevent_destroy = true.
resource "aws_instance" "protected" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instances[local.protected_instance_name].instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.instances[local.protected_instance_name].key_name
  associate_public_ip_address = false

  root_block_device {
    volume_type = var.instances[local.protected_instance_name].root_volume_type
    volume_size = var.instances[local.protected_instance_name].root_volume_size
    iops = contains(
      ["io1", "io2"],
      var.instances[local.protected_instance_name].root_volume_type
    ) ? var.instances[local.protected_instance_name].root_volume_iops : null
    encrypted = true
  }

  tags = merge(local.common_tags, {
    Name = local.protected_instance_name
  })

  lifecycle {
    # Prevent an accidental terraform destroy from deleting this instance.
    prevent_destroy = true
  }
}
