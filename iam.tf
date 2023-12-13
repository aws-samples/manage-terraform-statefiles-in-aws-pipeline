#### CodeBuild permissions

data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket_backend.arn}/*",
      "${aws_s3_bucket.s3_bucket_backend.arn}"
    ]
    effect = "Allow"
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:Describe*",
      "dynamodb:Get*",
      "dynamodb:List*"
    ]
    resources = ["${aws_dynamodb_table.dynamodb_tfstate_lock.arn}"]
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name   = var.codebuild_policy_name
  path   = "/"
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment1" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  role       = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment3" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role       = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment4" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
  role       = aws_iam_role.codebuild_role.id
}

#### Lambda permissions

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaTrustPolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    sid    = "LambdaPolicy"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:*:*"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name   = var.lambda_policy_name
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
