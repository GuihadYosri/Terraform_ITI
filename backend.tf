terraform {
  backend "s3" {
    bucket         = "day1-terraform-lab"  # Your S3 bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"  # Your AWS region
    dynamodb_table = "terraform-day1-lab"  # Your DynamoDB table for locking
  }
}
