# Define the AWS provider configuration with your desired region.
provider "aws" {
  region = "us-east-1"  # Specify the AWS region where resources will be created
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Machine Image (AMI) ID
  instance_type = "t2.micro"               # EC2 instance type
}
