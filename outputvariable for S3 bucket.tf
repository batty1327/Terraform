# Configure the AWS provider with authentication credentials and region.
provider "aws" {
  region     = "us-west-2"          # Set the AWS region to us-west-2.
  access_key = "*************"       # Replace with your AWS access key.
  secret_key = "*************"       # Replace with your AWS secret key.
}

# Define an AWS S3 bucket resource.
resource "aws_s3_bucket" "example" {
  bucket = "${var.environment}1234-example-bucket"
  acl    = "private"
}

# Define an output variable to display the bucket name.
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
