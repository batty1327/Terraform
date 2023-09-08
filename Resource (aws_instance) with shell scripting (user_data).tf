# Define the AWS provider configuration.
provider "aws" {
  region     = "ap-south-1"         # Specify the AWS region you're working in
  access_key = "*****************"  # Your AWS access key
  secret_key = "*****************"  # Your AWS secret key (Keep this secret!)
}

# Create an AWS EC2 instance resource named "myec2".
resource "aws_instance" "myec2" {
  ami                    = "ami-0d81306eddc614a45"  # Amazon Machine Image (AMI) ID
  instance_type          = "t2.small"               # Instance type (e.g., t2.micro, t2.small)
  key_name               = "tf-key-pair"           # SSH key pair for accessing the instance
  tags = {
    Name = "terraform-example"  # Name tag for the instance
  }
  
  # User data script to be executed when the instance launches.
  user_data = <<-EOF
#!/bin/bash
yum install httpd -y                                      # Install Apache web server
service httpd start                                       # Start the Apache service
cd /var/www/html                                          # Change to the web server's document root
touch index.html                                           # Create an index.html file
echo "hello from terraform" > index.html                  # Add content to the HTML file
EOF
}

# Define a security group named "ownsg" for the EC2 instance.
resource "aws_security_group" "ownsg" {
  name = "own-sg"  # Name of the security group

  # Ingress rules (allow incoming traffic)
  ingress {
    from_port   = 80      # Allow incoming traffic on port 80 (HTTP)
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP (0.0.0.0/0)
  }
  ingress {
    from_port   = 22      # Allow incoming SSH traffic on port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules (allow outgoing traffic)
  egress {
    from_port   = 0       # Allow all outgoing traffic
    to_port     = 0
    protocol    = "-1"    # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an AWS key pair named "tf-key-pair" for SSH access to instances.
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"  # Key pair name
  public_key = tls_private_key.rsa.public_key_openssh  # Public key from TLS private key
}

# Generate a TLS private key for SSH key pair.
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file.
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem  # Private key content
  filename = "tf-key-pair"                        # Filename to save the key
}