variable "aws_region" {
  description = "AWS region where the EC2 instances will be created."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment tag applied to every EC2 instance."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag applied to every EC2 instance."
  type        = string
  default     = "devops"
}

variable "subnet_id" {
  description = "Subnet in which all five EC2 instances will be launched."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups to associate with every EC2 instance."
  type        = list(string)
}

# One map is the source of truth for all five instances.
# The key becomes the logical instance name used in tags and outputs.
variable "instances" {
  description = "Five EC2 instance definitions, each with its own sizing, storage and key pair."
  type = map(object({
    instance_type      = string
    root_volume_type   = string
    root_volume_size   = number
    root_volume_iops   = optional(number)
    key_name           = string
  }))

  validation {
    condition     = length(var.instances) == 5
    error_message = "Exactly five EC2 instances must be supplied in the instances map."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      contains(["gp3", "gp2", "io1", "io2"], instance.root_volume_type)
    ])
    error_message = "root_volume_type must be gp3, gp2, io1, or io2."
  }

  validation {
    condition = anytrue([
      for instance in values(var.instances) :
      contains(["io1", "io2"], instance.root_volume_type)
    ])
    error_message = "At least one instance must use io1 or io2 storage."
  }
}
