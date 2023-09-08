# Define a Terraform variable named "vpc_id"

variable "vpc_id" {
  # No specific type is specified, so it defaults to "any" type.
  # This means the variable can hold values of any type.

  # No default value is specified, so the variable must be explicitly set
  # when using this Terraform configuration, either through a variable file or
  # as a command-line argument.
}
