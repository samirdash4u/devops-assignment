# Task 1 - Multi-Instance EC2 Terraform Module

The reusable module is in `module/`. The files in the directory root demonstrate consuming that module.

## Usage

```bash
# Edit subnet_id, security groups and the five existing key-pair names in terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

The single `instances` map drives all five instances. The module validates that exactly five instances are supplied and that at least one uses `io1` or `io2`.

`monitoring-01` is protected using `prevent_destroy = true`.

## Why there are two resource blocks inside the module

Terraform lifecycle settings such as `prevent_destroy` must be statically known and cannot be switched dynamically based on `each.value`. Therefore four instances are created by one `for_each` resource and the protected instance is created by a second resource, while both are still driven by the same `instances` input map.
