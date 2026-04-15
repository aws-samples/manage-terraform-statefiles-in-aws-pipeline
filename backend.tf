terraform {
  backend "s3" {
    bucket         = "tfbackend-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}
