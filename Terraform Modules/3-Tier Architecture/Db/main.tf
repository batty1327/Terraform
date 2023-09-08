# Create an AWS RDS (Relational Database Service) instance
resource "aws_db_instance" "rds" {
  engine                 = "mysql"                # Specify the database engine (MySQL in this case)
  instance_class         = "db.t3.micro"          # Specify the instance type
  allocated_storage      = 20                     # Specify the allocated storage in GB
  storage_type           = "gp2"                  # Specify the storage type (General Purpose SSD)
  username               = "root"                 # Specify the database username
  password               = "Pass1234"             # Specify the database password
  vpc_security_group_ids = [aws_security_group.dbsg.id]  # Attach a security group to control network traffic
  identifier             = "myrds"                # Specify a unique identifier for the RDS instance
  db_subnet_group_name   = aws_db_subnet_group.mydbsubnetgroup.id  # Associate with a subnet group
}

# Create a security group for the RDS instance
resource "aws_security_group" "dbsg" {
  name   = "db-sg"                     # Specify a name for the security group
  vpc_id = var.vpc_id                   # Use the VPC ID provided as a variable

  ingress {
    from_port   = 3306                  # Allow incoming traffic on port 3306 (MySQL)
    to_port     = 3306                  # Allow traffic to port 3306
    protocol    = "tcp"                 # Specify the protocol as TCP
    cidr_blocks = ["10.0.16.0/20"]      # Allow incoming traffic from the specified CIDR block
  }

  egress {
    from_port   = 0                     # Allow all outbound traffic
    to_port     = 0                     # Allow traffic to all ports
    protocol    = "-1"                  # Specify -1 to allow all protocols
    cidr_blocks = ["0.0.0.0/0"]         # Allow outbound traffic to any destination
  }
}

# Create an RDS subnet group and associate it with specified subnets
resource "aws_db_subnet_group" "mydbsubnetgroup" {
  name        = "mydbsubnetgroup"         # Specify a name for the subnet group
  subnet_ids  = [var.dbsubnetid, var.appsubnetid]  # List of subnet IDs to associate
  description = "db subnet group"         # Description for the subnet group
}
