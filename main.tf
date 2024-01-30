#### S3

resource "aws_s3_bucket" "s3_bucket_backend" {
  #checkov:skip=CKV_AWS_145: Lifecycle configuration not required for TF state bucket
  #checkov:skip=CKV2_AWS_61: Lifecycle configuration not required for TF state bucket
  #checkov:skip=CKV_AWS_144: Cross-region replication not required for TF state bucket
  #checkov:skip=CKV2_AWS_62: Event notifications not required for TF state bucket
  #checkov:skip=CKV_AWS_145: No KMS encryption needed for TF state bucket
  #checkov:skip=CKV_AWS_21: No versioning needed for TF state bucket
  #checkov:skip=CKV_AWS_18: No logging needed for TF state bucket
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "s3_bucket_backend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
  bucket     = aws_s3_bucket.s3_bucket_backend.id
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_bucket_backend.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_version" {
  bucket = aws_s3_bucket.s3_bucket_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "terraform_folder" {
  bucket = aws_s3_bucket.s3_bucket_backend.id
  key    = "terraform.tfstate"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_access" {
  bucket                  = aws_s3_bucket.s3_bucket_backend.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#### CodeCommit

resource "aws_codecommit_repository" "codecommit_repo" {
  #checkov:skip=CKV2_AWS_37: CodeCommit approval step not needed
  repository_name = "codebuild-terraform"
  description     = "Repository for application source code"
}

#### CodeBuild

resource "aws_codebuild_project" "codebuild_project_plan" {
  name         = var.codebuild_plan_project_name
  description  = "Terraform plan for deploying lambda"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = var.container_type
  }

  source {
    type            = "CODECOMMIT"
    buildspec       = var.buildspec_plan
    location        = aws_codecommit_repository.codecommit_repo.clone_url_http
    git_clone_depth = 0
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.codebuild_plan_loggroup_name
      stream_name = var.codebuild_plan_stream_name
    }
  }
}

resource "aws_codebuild_project" "codebuild_project_apply" {
  name         = var.codebuild_apply_project_name
  description  = "Terraform apply for deploying lambda"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = var.container_type
  }

  source {
    type            = "CODECOMMIT"
    buildspec       = var.buildspec_apply
    location        = aws_codecommit_repository.codecommit_repo.clone_url_http
    git_clone_depth = 0
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.codebuild_apply_loggroup_name
      stream_name = var.codebuild_apply_stream_name
    }
  }
}

#### Lambda

# Commented for the first run, uncomment it in your second run when you prepare your application

# data "archive_file" "lambda_archive_file" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda/"
#   output_path = "${path.module}/lambda/main.zip"
# }

# resource "aws_lambda_function" "lambda" {
#   #checkov:skip=CKV_AWS_50: X-ray tracing not required
#   #checkov:skip=CKV_AWS_115: This lambda function doesnt need function-level concurrent execution limit
#   #checkov:skip=CKV_AWS_117: This lambda function doesnt need to access any resources within VPC
#   #checkov:skip=CKV_AWS_116: Dead Letter Queue(DLQ) not required for this lambda
#   #checkov:skip=CKV_AWS_173: Lambda stores environment variables securely by encrypting them at rest
#   #checkov:skip=CKV_AWS_272: code-signing not needed
#   description      = "Sample Lambda function"
#   filename         = join("", data.archive_file.lambda_archive_file.*.output_path)
#   function_name    = "tf-codebuild"
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "main.lambda_handler"
#   source_code_hash = join("", data.archive_file.lambda_archive_file.*.output_base64sha256)
#   runtime          = "python3.9"
# }

#### DynamoDB

resource "aws_dynamodb_table" "dynamodb_tfstate_lock" {
  #checkov:skip=CKV2_AWS_16: Auto Scaling not required for TF state bucket
  #checkov:skip=CKV_AWS_28: Dynamodb point in time recovery not required for TF state bucket
  #checkov:skip=CKV_AWS_119: KMS Customer Managed CMK not required for TF state bucket
  name           = "tfstate-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

}

#### Cloudwatch log group

resource "aws_cloudwatch_log_group" "lambda_loggroup" {
  name              = "/aws/lambda/logs"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "codebuild_loggroup" {
  name              = "/aws/codebuild/logs"
  retention_in_days = 14
}

