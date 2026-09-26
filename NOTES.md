# NOTES.md

## Task 1 - Multi-instance EC2 provisioning

The five instances are represented as objects inside one `instances` variable. Terraform uses `for_each` to create one EC2 resource for each object. This avoids maintaining five nearly identical resource blocks.

Each object contains its own instance type, root volume type, root volume size, and key pair, so the configuration remains data-driven.

The example protects the `monitoring-01` instance with `prevent_destroy = true`. I chose this instance because monitoring infrastructure is normally considered shared infrastructure: accidentally deleting it can remove visibility into the rest of the environment during an incident.

The module outputs two maps: instance name to instance ID, and instance name to private IP.

## Task 2 - Remote state and locking

With local state, Terraform writes the state file to the local working directory. If two engineers run `terraform apply` against the same configuration and local state at the same time, they can both read the same old state and attempt conflicting changes. This can result in race conditions, stale state, failed operations, or state corruption depending on timing and the operation being performed.

The S3 backend gives the team a shared state location. The DynamoDB table provides a lock so that only one Terraform operation can hold the state lock at a time. A second operation waits/fails instead of concurrently modifying the same state.

For a real production setup, I would also enable S3 versioning, encryption, restricted bucket access, and ideally separate the bootstrap of the backend resources from the workloads that consume the backend.

## Task 3 - Multi-account IAM

Account A contains:

- `group1`: intended for CLI/programmatic access.
- `group2`: intended for users who need both console and CLI access.
- `roleA`: administrative access to AWS services except IAM.
- `roleB`: can only call `sts:AssumeRole` against roleC in Account B.

Account B contains:

- `roleC`: access to one named S3 bucket only.
- The trust policy allows only roleB's exact ARN from Account A.

### Would I give engine and ci long-lived access keys in production?

Generally, no. For CI, I would prefer short-lived credentials using an identity provider such as GitHub Actions OIDC, or another workload identity mechanism supported by the CI platform. For a human engineer using the CLI, I would prefer federation/SSO and short-lived credentials.

Long-lived IAM user access keys create a persistent credential that can be leaked through source code, CI logs, shell history, local files, or a compromised workstation. Short-lived credentials reduce the lifetime of a stolen credential and make rotation less painful.

The assignment explicitly asks for IAM users and groups, so the Terraform configuration models those resources, but the production recommendation is to avoid long-lived keys where possible.

### Why trust roleB specifically instead of Account A root?

Trusting the Account A root principal is broader than trusting roleB's ARN. A principal of the form `arn:aws:iam::<account-id>:root` represents the AWS account as a trusted principal, and IAM delegation can allow identities in that account to use the trust relationship subject to the applicable policies.

Trusting `arn:aws:iam::<account-id>:role/roleB` expresses the intended boundary much more precisely: roleC is intended to be assumable by roleB, not by arbitrary principals from Account A.

This is especially important for least privilege and makes the trust policy communicate the actual design intent.

## Task 4 - Least privilege CI policy

The CI policy deliberately does not grant:

- `ecr:*` - the pipeline only needs the actions required to authenticate and push images.
- ECR repository access to every repository - the resources are limited to one repository.
- `ecs:*` - the pipeline only needs to register task definitions, update one service, and describe the relevant ECS resources.
- S3 write/delete permissions - build artifacts are read-only for this pipeline.
- IAM permissions - the pipeline does not need to create or modify identities.
- EC2, VPC, Lambda, CloudFormation, or other unrelated service permissions.
- `s3:*` - only object read actions are included for the specified artifact bucket.

For ECR, some API calls such as authentication are not resource-scoped in the same way as repository actions, so the policy uses `Resource: "*"` only where AWS requires it. Repository-specific ECR actions are scoped to the single repository ARN.

## Task 5 - Find and fix the bug

There are two separate issues.

### Issue 1: trust policy principal

The broken configuration uses:

`arn:aws:iam::000000000000:user/roleB`

That ARN describes an IAM user named `roleB`, not an IAM role. The assignment says roleB is a role. The correct principal is:

`arn:aws:iam::000000000000:role/roleB`

The trust policy therefore needs to trust the role ARN.

### Issue 2: roleC S3 permissions

The broken permissions policy grants:

`Action = "s3:*"`

and

`Resource = "*"`

That gives roleC broad S3 permissions across the account rather than access to the one named bucket requested by the assignment. It also grants write/delete/admin-style operations when the task only says that roleC needs full access to one specific bucket.

The fixed example scopes the bucket-level and object-level permissions to the named bucket. Bucket-level actions use the bucket ARN, while object actions use the bucket ARN with `/*`.
