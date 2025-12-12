variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC. Used for Security Group ingress rules."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

variable "environment" {
  description = "Environment name, e.g. dev."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "private_route_table_ids" {
  description = "List of Route Table IDs for private and non-routable subnets. Used for S3 Gateway Endpoint association."
  type        = list(string)
}

variable "interface_subnet_ids" {
  description = "List of Subnet IDs for private and non-routable subnets. Used for Interface Endpoint ENI creation."
  type        = list(string)
}