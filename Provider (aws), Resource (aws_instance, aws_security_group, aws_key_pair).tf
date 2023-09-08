# Define the AWS provider configuration with your access key, secret key, and desired region.
provider "aws" {
  region     = "ap-south-1"                  # AWS region where resources will be created
  access_key = "********************"        # Your AWS access key (replace with your own)
  secret_key = "********************"        # Your AWS secret key (replace with your own)
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "myec2" {
  ami           = "ami-0d81306eddc614a45"     # Amazon Machine Image (AMI) ID
  instance_type = "t2.small"                  # EC2 instance type
  vpc_security_group_ids = [aws_security_group.ownsg.id]  # Attach the security group created below
  key_name      = "tf-key-pair"               # SSH key pair name
  tags = {
    Name = "terraform-example"                # Name tag for the EC2 instance
  }
}

# Define an AWS security group resource.
resource "aws_security_group" "ownsg" {
  name = "own-sg"                             # Name for the security group

  # Define inbound rules:
  # 1. Allow incoming traffic on port 80 (HTTP) from any source.
  # 2. Allow incoming traffic on port 22 (SSH) from any source.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]               # Allow traffic from any IP (0.0.0.0/0)
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]               # Allow SSH from any source
  }

  # Define an egress rule allowing all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                        # All protocols
    cidr_blocks = ["0.0.0.0/0"]               # Allow traffic to any IP (0.0.0.0/0)
  }
}

# Define an AWS key pair resource.
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"                  # Name of the key pair
  public_key = tls_private_key.rsa.public_key_openssh  # Use the public key from the generated TLS key pair
}

# Generate an RSA private key for the key pair.
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096                            # RSA key size (4096 bits)
}

# Create a local file to store the private key.
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem  # Store the private key content
  filename = "tf-key-pair"                    # Name the local file
}
