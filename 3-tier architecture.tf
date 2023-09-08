# Define the AWS provider configuration with your desired region and credentials.
provider "aws" {
  region     = "ap-south-1"                     # Specify the AWS region where resources will be created
  access_key = "***************************"    # Your AWS access key (replace with your own)
  secret_key = "***************************"    # Your AWS secret key (replace with your own)
}

# Define an AWS VPC resource.
resource "aws_vpc" "customvpc" {
  cidr_block = "10.0.0.0/16"                    # Define the IP address range for the VPC
  tags = {
    Name = "Custom vpc"                         # Name tag for the VPC
  }
}

# Define an AWS Internet Gateway resource.
resource "aws_internet_gateway" "custominternetgateway" {
  vpc_id = aws_vpc.customvpc.id                 # Attach the Internet Gateway to the VPC created above
}

# Define AWS Subnet resources for different availability zones.
resource "aws_subnet" "websubnet" {
  cidr_block        = "10.0.0.0/20"             # IP address range for the subnet
  vpc_id            = aws_vpc.customvpc.id      # Attach the subnet to the VPC
  availability_zone = "ap-south-1a"             # Availability Zone for this subnet
}

resource "aws_subnet" "appsubnet" {
  cidr_block        = "10.0.16.0/20"             # IP address range for the subnet
  vpc_id            = aws_vpc.customvpc.id       # Attach the subnet to the VPC
  availability_zone = "ap-south-1b"              # Availability Zone for this subnet
}

resource "aws_subnet" "dbsubnet" {
  cidr_block        = "10.0.32.0/20"              # IP address range for the subnet
  vpc_id            = aws_vpc.customvpc.id           # Attach the subnet to the VPC
  availability_zone = "ap-south-1a"                # Availability Zone for this subnet
}

# Define AWS Route Table resources.
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.customvpc.id                   # Associate this route table with the VPC
  route {
    cidr_block = "0.0.0.0/0"                      # Default route for internet traffic
    gateway_id = aws_internet_gateway.custominternetgateway.id  # Target the Internet Gateway
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.customvpc.id                    # Associate this route table with the VPC
}

# Associate Subnets with Route Tables.
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.websubnet.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "pvt_association" {
  subnet_id      = aws_subnet.appsubnet.id
  route_table_id = aws_route_table.pvtrt.id
}

resource "aws_route_table_association" "db_association" {
  subnet_id      = aws_subnet.dbsubnet.id
  route_table_id = aws_route_table.pvtrt.id
}

# Define AWS EC2 instances for web, app, and RDS.
resource "aws_instance" "webec2" {
  ami                    = "ami-0d81306eddc614a45"                 # Amazon Machine Image (AMI) ID
  instance_type          = "t2.micro"                             # EC2 instance type
  vpc_security_group_ids = [aws_security_group.websg.id]           # Attach a security group
  key_name               = "tf-key-pair"                         # SSH key pair for access
  subnet_id              = aws_subnet.websubnet.id               # Deploy in the web subnet
  tags = {
    Name = "web"  # Name tag for the EC2 instance
  }
}

resource "aws_instance" "appec2" {
  ami                    = "ami-0d81306eddc614a45"                 # Amazon Machine Image (AMI) ID
  instance_type          = "t2.micro"                                 # EC2 instance type
  vpc_security_group_ids = [aws_security_group.appsg.id]              # Attach a security group
  key_name               = "tf-key-pair"                            # SSH key pair for access
  subnet_id              = aws_subnet.appsubnet.id                   # Deploy in the app subnet
  tags = {
    Name = "app"  # Name tag for the EC2 instance
  }
}
# Define an AWS RDS (Relational Database Service) instance resource.
resource "aws_db_instance" "rds" {
  engine                 = "mysql"          # Database engine (MySQL in this case)
  instance_class         = "db.t3.micro"    # RDS instance type
  allocated_storage      = 20               # Storage allocated to the RDS instance (in GB)
  storage_type           = "gp2"            # Storage type (General Purpose SSD)
  username               = "root"           # Database username
  password               = "Pass1234"       # Database password
  vpc_security_group_ids = [aws_security_group.dbsg.id]  # Attach a security group
  identifier             = "myrds"          # Identifier for the RDS instance
  db_subnet_group_name   = aws_db_subnet_group.mydbsubnetgroup.id  # Attach a DB subnet group
}

# Define an AWS DB Subnet Group resource.
resource "aws_db_subnet_group" "mydbsubnetgroup" {
  name        = "mydbsubnetgroup"    # Name of the DB subnet group
  subnet_ids  = [aws_subnet.dbsubnet.id, aws_subnet.appsubnet.id]  # Attach subnets
  description = "db subnet group"    # Description of the DB subnet group
}

# Define an AWS security group for the web tier.
resource "aws_security_group" "websg" {
  name   = "web-sg"                 # Name of the security group
  vpc_id = aws_vpc.customvpc.id     # Attach the security group to the VPC

  # Ingress rules for allowing incoming traffic:
  ingress {
    from_port   = 80                 # Allow HTTP traffic
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]      # Allow traffic from any IP (0.0.0.0/0)
  }
  ingress {
    from_port   = 22                 # Allow SSH traffic
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an AWS security group for the app tier.
resource "aws_security_group" "appsg" {
  name   = "app-sg"                 # Name of the security group
  vpc_id = aws_vpc.customvpc.id     # Attach the security group to the VPC

  # Ingress rule for a specific port range.
  ingress {
    from_port   = 9000               # Allow traffic on port 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]   # Allow traffic from a specific IP range
  }

  # Egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an AWS security group for the database tier.
resource "aws_security_group" "dbsg" {
  name   = "db-sg"                  # Name of the security group
  vpc_id = aws_vpc.customvpc.id     # Attach the security group to the VPC

  # Ingress rule to allow MySQL database traffic.
  ingress {
    from_port   = 3306               # Allow MySQL traffic
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/20"]   # Allow traffic from a specific IP range
  }

  # Egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
