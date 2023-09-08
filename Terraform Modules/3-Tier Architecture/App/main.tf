# Create an AWS EC2 instance for the 'app' tier.
resource "aws_instance" "appec2" {
  ami                    = "ami-0d81306eddc614a45"  # Amazon Machine Image (AMI) to use for the instance.
  instance_type          = "t2.micro"               # Instance type (size).
  vpc_security_group_ids = [aws_security_group.appsg.id]  # List of security group IDs to associate with the instance.
  key_name               = "tf-key-pair"           # SSH key pair to use for instance access.
  subnet_id              = var.subnet_id            # Subnet ID where the instance will be launched.
  tags = {
    Name = "app"         # Tags for the EC2 instance for identification.
  }
}

# Define a security group for the 'app' tier.
resource "aws_security_group" "appsg" {
  name   = "app-sg"      # Name of the security group.
  vpc_id = var.vpc_id    # ID of the Virtual Private Cloud (VPC) where the security group is created.

  # Define inbound rules (ingress) for incoming traffic to the security group.
  ingress {
    from_port   = 9000                 # Allowed incoming port range (from port).
    to_port     = 9000                 # Allowed incoming port range (to port).
    protocol    = "tcp"                # Protocol for incoming traffic.
    cidr_blocks = ["10.0.0.0/20"]      # Allowed source IP CIDR blocks for incoming traffic.
  }

  # Define outbound rules (egress) for outgoing traffic from the security group.
  egress {
    from_port   = 0                    # Allow all outgoing traffic from any port.
    to_port     = 0                    # Allow all outgoing traffic to any port.
    protocol    = "-1"                 # Allow all outbound protocols.
    cidr_blocks = ["0.0.0.0/0"]        # Allow outgoing traffic to any destination IP.
  }
}
