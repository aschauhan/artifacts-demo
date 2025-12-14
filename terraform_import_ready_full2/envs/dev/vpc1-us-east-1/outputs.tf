# Outputs for Core Networking Components

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.public_subnets.subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.private_subnets.subnet_ids
}

output "non_routable_subnet_ids" {
  description = "IDs of the non-routable subnets."
  value       = module.non_routable_subnets.subnet_ids
}

# Outputs for VPC Endpoints Module

output "s3_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint."
  value       = module.vpc_endpoints.s3_endpoint_id
}

output "interface_endpoint_ids" {
  description = "A list of all Interface Endpoint IDs (EC2, SSM, SSMMessages, EC2Messages)."
  value       = module.vpc_endpoints.interface_endpoint_ids
}

output "interface_endpoints_sg_id" {
  description = "The ID of the security group used for Interface Endpoints."
  value       = module.vpc_endpoints.interface_endpoints_sg_id
}