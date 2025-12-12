# This file contains only output declarations, referencing the resources defined in main.tf.
output "s3_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint."
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "interface_endpoint_ids" {
  description = "List of Interface Endpoint IDs."
  # Collecting IDs from separate resources into a single list
  value = [
    aws_vpc_endpoint.ec2_endpoint.id,
    aws_vpc_endpoint.ssm_endpoint.id,
    aws_vpc_endpoint.ssmmessages_endpoint.id,
    aws_vpc_endpoint.ec2messages_endpoint.id,
  ]
}

output "interface_endpoints_sg_id" {
  description = "The ID of the security group used for Interface Endpoints."
  value       = aws_security_group.interface_endpoints_sg.id
}