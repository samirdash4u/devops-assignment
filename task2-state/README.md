# Task 2 - Remote State and Locking

There is a small bootstrap dependency: Terraform cannot use an S3 backend until the S3 bucket exists, and the DynamoDB locking table also needs to exist before Terraform can lock state.

The provided `bootstrap.sh` handles this in two phases:

1. Run Terraform with local state to create the S3 bucket and DynamoDB lock table.
2. Run `terraform init -reconfigure` so Terraform migrates the local state to S3 and starts using the DynamoDB table for locking.

## Bootstrap

```bash
cd task2-state
./bootstrap.sh my-company-terraform-state-12345
```

The bucket name must be globally unique.

## Normal operation after bootstrap

```bash
terraform plan
terraform apply
```

The backend block in `backend.tf` deliberately does not contain Terraform variables. Backend configuration is initialized before normal variables are evaluated, so values such as the bucket name are passed with `-backend-config` during initialization.

## Why locking matters

With local state, two engineers can run Terraform at the same time against the same configuration while each process has its own local state file. They can therefore both make decisions from stale state and perform conflicting operations.

With the S3 backend plus DynamoDB lock, Terraform acquires a shared lock before changing the state. A concurrent Terraform operation cannot simply modify the same state at the same time.

## Security notes

The state bucket has:

- versioning enabled
- server-side encryption enabled
- public access blocked
- bucket-owner-enforced object ownership

For a larger production platform, I would also restrict bucket and DynamoDB access to the Terraform execution roles and consider a customer-managed KMS key if required by organizational policy.
