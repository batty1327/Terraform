# Define output variables to expose specific resource attributes.

# Output the ID of the 'websubnet' resource.
output "websubnet_id" {
  value = aws_subnet.websubnet.id
}

# Output the ID of the 'appsubnet' resource.
output "appsubnet_id" {
  value = aws_subnet.appsubnet.id
}

# Output the ID of the 'customvpc' resource.
output "vpcid" {
  value = aws_vpc.customvpc.id
}
