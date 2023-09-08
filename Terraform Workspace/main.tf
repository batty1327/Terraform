# Define the AWS provider block with the specified region, access key, and secret key.
provider "aws" {
  region     = "ap-south-1"                    # AWS region to operate in (Asia Pacific - Mumbai).
  access_key = "********************"          # AWS access key (Replace with your own access key).
  secret_key = "********************"          # AWS secret key (Replace with your own secret key).
}

# Define an AWS S3 bucket resource.
resource "aws_s3_bucket" "example" {
  bucket = "${var.environment}batty1327"  # The name of the S3 bucket (uses a variable called "environment" to generate the name).
  acl    = "private"                      # Access control list (ACL) set to "private" (other options include "public-read", "public-read-write", etc.).
}

# Define an output block to display the name of the created S3 bucket.
output "bucket_name" {
  value = aws_s3_bucket.example.bucket  # Display the bucket name associated with the "example" resource.
}
