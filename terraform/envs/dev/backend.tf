terraform {
  backend "s3" {
    bucket         = "votingapp-tf-state-dev-123456"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
