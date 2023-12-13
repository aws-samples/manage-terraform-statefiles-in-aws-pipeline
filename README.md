# aws-codebuild-terraform

This repo was created as part of the blog - "Best practices for managing Terraform State files in AWS CI Pipeline" 

## Best Practices for handling state files

The recommended practice for managing state files is to use Terraform’s built-in support for remote backends. There are several ways to store and manage Terraform state files on remote backends are as stated below:

Remote backend on Amazon S3: You can configure Terraform to store state files in an Amazon S3 bucket which provides a durable and scalable storage solution for your state files. Storing on S3 also enables collaboration and sharing of state files among team members. 

Remote backend on S3 with Amazon DynamoDB: In addition to using a S3 bucket for managing the files, you can use a DynamoDB table to lock the state file to ensure that only one person can modify a particular state file at any given time, preventing conflicts and enabling safe concurrent access to the state file.

## AWS configurations for managing state files

1.	Create an S3 bucket using Terraform. Implement security measures for an Amazon S3 bucket state file by creating an IAM or S3 Bucket Policy to restrict access, configuring object versioning for data protection and recovery, and enabling AES256 encryption with SSE-KMS for encryption control.

2.	Next create a DynamoDB table using Terraform with Primary key set to “LockID” and any additional configuration options such as read/write capacity units. Once the table is created, you will configure the Terraform backend to use it for state locking by specifying the table name in the terraform block of your configuration which you will see shortly in the next section.

This repo will explain how you can manage terraform state files efficiently in your Continuous Integration pipeline in AWS when used with AWS Developer Tools like AWS CodeCommit and AWS CodeBuild. 


