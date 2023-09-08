# Define the AWS provider configuration with your desired region and credentials.
provider "aws" {
  region     = "ap-south-1"             # Specify the AWS region where resources will be created
  access_key = "*********************"  # Your AWS access key (replace with your own)
  secret_key = "*********************"  # Your AWS secret key (replace with your own)
}

# Define variables for the server port and public CIDR block.
variable "server_port" {
  type    = number
  default = 80  # Default server port, can be overridden when using this configuration
}

variable "public_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]  # Default public CIDR block, allows traffic from any IP
}

# Define an AWS EC2 instance resource.
resource "aws_instance" "myec2" {
  ami           = "ami-0d81306eddc614a45"  # Amazon Machine Image (AMI) ID
  instance_type = "t2.small"              # EC2 instance type
  vpc_security_group_ids = [aws_security_group.ownsg.id]  # Attach a security group
  key_name      = "tf-key-pair"           # SSH key pair for access
  tags = {
    Name = "terraform-example"  # Name tag for the EC2 instance
  }
}

# Define an AWS security group resource.
resource "aws_security_group" "ownsg" {
  name = "own-sg"  # Name of the security group

  # Define ingress rules for allowing incoming traffic.
  ingress {
    from_port   = var.server_port  # Use the server_port variable as the from_port
    to_port     = var.server_port  # Use the server_port variable as the to_port
    protocol    = "tcp"
    cidr_blocks = var.public_cidr  # Use the public_cidr variable as the CIDR block
  }

  # Ingress rule for allowing SSH traffic.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic from any IP
  }

  # Egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic to any IP
  }
}

# Define an AWS key pair resource for SSH access.
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"  # Name of the key pair
  public_key = tls_private_key.rsa.public_key_openssh  # Use the public key from the generated TLS key pair
}

# Generate an RSA private key for the key pair.
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096  # RSA key size (4096 bits)
}

# Create a local file to store the private key.
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem  # Store the private key content
  filename = "tf-key-pair"  # Name the local file
}