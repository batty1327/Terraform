# Create a custom VPC with a specified CIDR block and tags.
resource "aws_vpc" "customvpc" {
  cidr_block = "10.0.0.0/16"  # Define the IPv4 CIDR block for the VPC.
  tags = {
    Name = "Custom vpc"       # Add a name tag to identify the VPC.
  }
}

# Create an Internet Gateway and attach it to the custom VPC.
resource "aws_internet_gateway" "custominternetgateway" {
  vpc_id = aws_vpc.customvpc.id  # Attach the Internet Gateway to the custom VPC.
}

# Create a public subnet within the custom VPC in Availability Zone ap-south-1a.
resource "aws_subnet" "websubnet" {
  cidr_block        = "10.0.0.0/20"           # Specify the subnet's IPv4 CIDR block.
  vpc_id            = aws_vpc.customvpc.id    # Associate the subnet with the custom VPC.
  availability_zone = "ap-south-1a"           # Specify the Availability Zone.
}

# Create an application subnet within the custom VPC in Availability Zone ap-south-1b.
resource "aws_subnet" "appsubnet" {
  cidr_block        = "10.0.16.0/20"          # Specify the subnet's IPv4 CIDR block.
  vpc_id            = aws_vpc.customvpc.id    # Associate the subnet with the custom VPC.
  availability_zone = "ap-south-1b"           # Specify the Availability Zone.
}

# Create a database subnet within the custom VPC in Availability Zone ap-south-1a.
resource "aws_subnet" "dbsubnet" {
  cidr_block        = "10.0.32.0/20"          # Specify the subnet's IPv4 CIDR block.
  vpc_id            = aws_vpc.customvpc.id    # Associate the subnet with the custom VPC.
  availability_zone = "ap-south-1c"           # Specify the Availability Zone.
}

# Create a public route table associated with the custom VPC.
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.customvpc.id  # Associate the route table with the custom VPC.

  # Define a default route to the Internet Gateway (0.0.0.0/0).
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custominternetgateway.id
  }
}

# Create a private route table associated with the custom VPC.
resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.customvpc.id  # Associate the route table with the custom VPC.
}

# Associate the public route table with the public subnet.
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.websubnet.id      # Specify the public subnet ID.
  route_table_id = aws_route_table.publicrt.id  # Specify the public route table ID.
}

# Associate the private route table with the application subnet.
resource "aws_route_table_association" "pvt_association" {
  subnet_id      = aws_subnet.appsubnet.id     # Specify the application subnet ID.
  route_table_id = aws_route_table.pvtrt.id    # Specify the private route table ID.
}

# Associate the private route table with the database subnet.
resource "aws_route_table_association" "db_association" {
  subnet_id      = aws_subnet.dbsubnet.id      # Specify the database subnet ID.
  route_table_id = aws_route_table.pvtrt.id    # Specify the private route table ID.
}
