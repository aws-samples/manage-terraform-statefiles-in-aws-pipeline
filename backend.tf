terraform {
  backend "s3" {
    bucket         = "tfbackend-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }
}
