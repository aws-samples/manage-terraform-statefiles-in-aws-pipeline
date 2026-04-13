# aws-codebuild-terraform

This repo was created as part of the blog - "Best practices for managing Terraform State files in AWS CI/CD Pipeline" 

## Prerequisites

- Terraform v1.11.0 or later (required for S3 native state locking with `use_lockfile`)

## Best Practices for handling state files

The recommended practice for managing state files is to use terraform's built-in support for remote backends.

Remote backend on Amazon Simple Storage Service (Amazon S3): 
You can configure terraform to store state files in an Amazon S3 bucket which provides a durable and scalable storage solution for your state files. Storing on Amazon S3 also enables collaboration that allows you to share state file with others.

State locking with S3 native locking:
By setting `use_lockfile = true` in the S3 backend configuration, Terraform creates a `.tflock` lock file in the same S3 bucket to prevent concurrent modifications to the state file. This eliminates the need for a separate DynamoDB table and simplifies your infrastructure.

> **Note:** `use_lockfile` requires Terraform v1.11.0 or later.

When deploying terraform on AWS, the preferred choice of managing state is using Amazon S3 with S3 native locking (`use_lockfile = true`).

## AWS configurations for managing state files

> **Important:** Before deploying, update the S3 bucket name in both `variable.tf` (`s3_bucket_name`) and `backend.tf` (`bucket`) to a globally unique name for your environment. These two values must refer to the same bucket.

1. Create an Amazon S3 bucket using terraform. Implement security measures for Amazon S3 bucket by creating an AWS Identity and Access Management (AWS IAM) policy or Amazon S3 Bucket Policy for restricting access, configuring object versioning for data protection and recovery, and enabling AES256 encryption with SSE-KMS for encryption control.

2. Configure the S3 backend with `use_lockfile = true` to enable state locking. Terraform will automatically manage a `.tflock` file in the S3 bucket to prevent concurrent state modifications. Ensure the IAM role used by Terraform has the minimum permissions: `s3:ListBucket` on the bucket, `s3:GetObject` and `s3:PutObject` on the state file, and additionally `s3:DeleteObject` on the lock file (`.tflock`).

3. For a single AWS account with multiple environments and projects, you can use a single Amazon S3 bucket. If you have multiple applications in multiple environments across multiple AWS accounts, you can create one Amazon S3 bucket for each account. In that Amazon S3 bucket, you can create appropriate folders for each environment, storing project state files with specific prefixes.

This repo will explain how you can manage terraform state files efficiently in your Continuous Integration pipeline in AWS when used with AWS Developer Tools like AWS CodeCommit and AWS CodeBuild. 

## Migrating from DynamoDB state locking

If you are currently using DynamoDB-based state locking (`dynamodb_table`), note that this mechanism is deprecated as of Terraform v1.11.0 and will be removed in a future minor version. The [HashiCorp S3 Backend documentation](https://developer.hashicorp.com/terraform/language/backend/s3) recommends the following migration path:

1. **Dual locking:** Add `use_lockfile = true` while keeping the existing `dynamodb_table` argument. Terraform will acquire locks from both S3 and DynamoDB before proceeding with any operation.
2. **Verify:** Run `plan` and `apply` several times to confirm S3 native locking is working correctly.
3. **Remove DynamoDB configuration:** Once verified, remove the `dynamodb_table` argument to complete the migration and eliminate the deprecation warning. The DynamoDB table and its associated IAM permissions can then be removed.

> **Note:** If your team has mixed Terraform versions, remain in the dual locking state until everyone has upgraded to v1.11.0 or later. S3 native locking relies on conditional writes (`If-None-Match` header), which may not be supported by all S3-compatible storage providers.
