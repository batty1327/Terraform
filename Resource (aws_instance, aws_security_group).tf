# Define the AWS provider configuration with your access key, secret key, and desired region.
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA5NYFT6IKJSH2V7W3"
  secret_key = "k/7K2iASYGVM609sPw1Uh345c/bqAoAQsKAntfpN"
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "myec2" {
  ami           = "ami-0d81306eddc614a45"    # Amazon Machine Image (AMI) ID
  instance_type = "t2.small"                 # EC2 instance type
  vpc_security_group_ids = [aws_security_group.ownsg.id]  # Attach the security group created below
  tags = {
    Name = "terraform-example"               # Name tag for the EC2 instance
  }
}

# Define an AWS security group resource.
resource "aws_security_group" "ownsg" {
  name = "own-sg"                            # Name for the security group

  # Define an inbound rule that allows incoming traffic on port 80 (HTTP) from any source.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]              # Allow traffic from any IP (0.0.0.0/0)
  }
}