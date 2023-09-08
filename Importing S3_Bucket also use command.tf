# Define an AWS S3 bucket resource named "bucket."
resource "aws_s3_bucket" "bucket" {
  bucket = "aclenabledwalibuck"  # Specify the name of the S3 bucket.
}

# Define an output variable to display the bucket's domain name.
output "bucketlink" {
  value = aws_s3_bucket.bucket.bucket_domain_name  # Retrieve the bucket's domain name.
}
