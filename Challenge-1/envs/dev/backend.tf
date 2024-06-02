terraform {
  backend "s3" {
    bucket         = "kpmgta-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-s3-bucket"
  }
}