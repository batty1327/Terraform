# Define a Terraform variable for the AWS region name.
variable "region_name" {
  type    = string          # Specifies the data type of the variable (string).
  default = "ap-south-1"   # Provides a default value for the variable.
}

# Define a Terraform variable for the server port.
variable "server_port" {
  type    = number  # Specifies the data type of the variable (number).
  default = 80      # Provides a default value for the variable.
}

# Define a Terraform variable for the public CIDR blocks.
variable "publiccidr" {
  type    = list(string)  # Specifies the data type of the variable (list of strings).
  default = ["0.0.0.0/0"] # Provides a default value for the variable as a list containing one CIDR block.
}
