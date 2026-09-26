# This root configuration demonstrates how the reusable module is consumed.
# The module itself lives in ./module and can be reused by another environment.
module "ec2" {
  source = "./module"

  aws_region        = var.aws_region
  environment      = var.environment
  owner             = var.owner
  subnet_id         = var.subnet_id
  security_group_ids = var.security_group_ids
  instances         = var.instances
}
