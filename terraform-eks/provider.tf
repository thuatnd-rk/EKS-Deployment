provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

terraform {
  backend "s3" {
    bucket = "ndthuat-us-east-1"
    key    = "logs"
    region = "us-east-1"
  }
}


