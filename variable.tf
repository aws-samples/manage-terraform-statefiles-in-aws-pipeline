variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "codecommit_repository_url" {
  type    = string
  default = "https://git-codecommit.eu-central-1.amazonaws.com/v1/repos/codebuild-terraform"
}

variable "s3_bucket_name" {
  type    = string
  default = "tfbackend-bucket"
}

variable "compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  type    = string
  default = "hashicorp/terraform:latest"
}

variable "container_type" {
  type    = string
  default = "LINUX_CONTAINER"
}

variable "codebuild_role_name" {
  type    = string
  default = "codebuild_tf_role"
}

variable "codebuild_policy_name" {
  type    = string
  default = "codebuild_tf_policy"
}

variable "codebuild_plan_project_name" {
  type    = string
  default = "codebuild_tf_plan"
}

variable "codebuild_apply_project_name" {
  type    = string
  default = "codebuild_tf_apply"
}

variable "buildspec_plan" {
  type    = string
  default = "buildspec-plan.yaml"
}

variable "buildspec_apply" {
  type    = string
  default = "buildspec-apply.yaml"
}

variable "lambda_role_name" {
  type    = string
  default = "lambda_tf_role"
}

variable "lambda_policy_name" {
  type    = string
  default = "lambda_tf_policy"
}

variable "codebuild_plan_loggroup_name" {
  type    = string
  default = "codebuild-plan-loggroup"
}

variable "codebuild_plan_stream_name" {
  type    = string
  default = "codebuild-plan-stream"
}

variable "codebuild_apply_loggroup_name" {
  type    = string
  default = "codebuild-apply-loggroup"
}

variable "codebuild_apply_stream_name" {
  type    = string
  default = "codebuild-apply-stream"
}


