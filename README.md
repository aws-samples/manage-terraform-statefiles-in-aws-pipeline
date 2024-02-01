# aws-codebuild-terraform

This repo was created as part of the blog - "Best practices for managing Terraform State files in AWS CI/CD Pipeline" 

## Best Practices for handling state files

The recommended practice for managing state files is to use terraform’s built-in support for remote backends.

Remote backend on Amazon Simple Storage Service (Amazon S3): 
You can configure terraform to store state files in an Amazon S3 bucket which provides a durable and scalable storage solution for your state files. Storing on Amazon S3 also enables collaboration that allows you to share state file with others.

Remote backend on Amazon S3 with Amazon DynamoDB: 
In addition to using an Amazon S3 bucket for managing the files, you can use an Amazon DynamoDB table to lock the state file so that only one person can modify a particular state file at any given time. This will help to avoid conflicts and enable safe concurrent access to the state file.

When deploying terraform on AWS, the preferred choice of managing state is using Amazon S3 with Amazon DynamoDB.

## AWS configurations for managing state files

1. Create an Amazon S3 bucket using terraform. Implement security measures for Amazon S3 bucket by creating an AWS Identity and Access Management (AWS IAM) policy or Amazon S3 Bucket Policy for restricting access, configuring object versioning for data protection and recovery, and enabling AES256 encryption with SSE-KMS for encryption control.

2. Next create an Amazon DynamoDB table using terraform with Primary key set to LockID and any additional configuration options such as read/write capacity units. Once the table is created, you will configure the terraform backend to use it for state locking by specifying the table name in the terraform block of your configuration.

3. For a single AWS account with multiple environments and projects, you can use a single Amazon S3 bucket. If you have multiple applications in multiple environments across multiple AWS accounts, you can create one Amazon S3 bucket for each account. In that Amazon S3 bucket, you can create appropriate folders for each environment, storing project state files with specific prefixes.

This repo will explain how you can manage terraform state files efficiently in your Continuous Integration pipeline in AWS when used with AWS Developer Tools like AWS CodeCommit and AWS CodeBuild. 


