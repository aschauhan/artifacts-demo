#
# Module Variables
#

variable "environment" {
  description = "The environment name (e.g., 'dev', 'prod'). Used for resource naming."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the endpoints will be created."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC, used to restrict Security Group ingress."
  type        = string
}

variable "region" {
  description = "The AWS region where the resources are deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "private_route_table_ids" {
  description = "A list of Route Table IDs for the Private and Non-Routable subnets to attach the S3 Gateway endpoint to."
  type        = list(string)
}

variable "interface_subnet_ids" {
  description = "A list of Subnet IDs for the Interface Endpoints (must contain only one subnet per Availability Zone)."
  type        = list(string)
}