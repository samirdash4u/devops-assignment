# DevOps Assignment - Terraform & AWS IAM

This repository contains a complete, commented solution for all five tasks in the assignment.

## Folder structure

```text
devops-assignment/
├── README.md
├── NOTES.md
├── SUBMISSION-CHECKLIST.md
├── .gitignore
│
├── task1-ec2/
│   ├── README.md
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── module/
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
│
├── task2-state/
│   ├── README.md
│   ├── versions.tf
│   ├── variables.tf
│   ├── backend.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── outputs.tf
│   ├── bootstrap.sh
│   └── terraform.tfvars.example
│
├── task3-iam/
│   ├── README.md
│   ├── account-a/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── policies/
│   │       └── roleA-admin-without-iam.json
│   └── account-b/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── policies/
│           ├── roleC-trust-policy.json
│           └── roleC-s3-policy.json
│
├── task4-ci-policy/
│   ├── README.md
│   └── ci-policy.json
│
└── task5-bug-fix/
    ├── broken-example.tf
    └── fixed-example.tf
```

## Important

The assignment provides placeholder AWS account IDs. They are retained in the solution so the code maps directly to the question. Replace them only when deploying to real AWS accounts.

No credentials, access keys, or real secrets are included.

## Formatting and validation

Terraform is not installed in the packaging environment used to create this archive, so AWS API calls and `terraform validate` could not be executed here. The configuration has been structured and formatted for Terraform, but you should run the following locally before submission:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

For the two-account IAM setup, run the Account B configuration using Account B credentials and Account A configuration using Account A credentials.
