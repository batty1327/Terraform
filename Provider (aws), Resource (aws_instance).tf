# Define the AWS provider configuration with your access key, secret key, and desired region.
provider "aws" {
  region     = "ap-south-1"                  # Specify the AWS region where resources will be created
  access_key = "*******************"          # Your AWS access key (replace with your own)
  secret_key = "**********************"       # Your AWS secret key (replace with your own)
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "myec2" {
  ami           = "ami-0d81306eddc614a45"     # Amazon Machine Image (AMI) ID
  instance_type = "t2.micro"                  # EC2 instance type
  tags = {
    Name = "terraform-example"                # Name tag for the EC2 instance
  }
}