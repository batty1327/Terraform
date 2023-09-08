# Define the AWS provider configuration with your desired region.
provider "aws" {
  region = "ap-south-1"  # Specify the AWS region where resources will be created
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "myec2" {
  ami           = "ami-0d81306eddc614a45"  # Amazon Machine Image (AMI) ID
  instance_type = "t2.micro"               # EC2 instance type
  tags = {
    Name = "terraform-example"            # Name tag for the EC2 instance
  }
}
