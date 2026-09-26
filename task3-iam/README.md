# Task 3 - Multi-account IAM

Run Account A and Account B Terraform configurations separately using credentials that have administrative/IAM permissions in the respective account.

## Account B first

Create roleC in Account B first because Account A roleB's policy refers to roleC's ARN.

```bash
cd account-b
terraform init
terraform plan
terraform apply
```

Then deploy Account A:

```bash
cd ../account-a
terraform init
terraform plan
terraform apply
```

For a real implementation, use separate AWS CLI profiles or role assumption for the two accounts.
