variable "environment" {
  type        = string
  description = "Environment name, e.g. prod (import)."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR."
}

variable "additional_cidrs" {
  type        = list(string)
  default     = []
  description = "Additional CIDR blocks for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)."
}

variable "nonroutable_subnet_cidrs" {
  type        = list(string)
  description = "Non-routable subnet CIDRs (one per AZ)."
}

variable "enable_private_nat_gateway" {
  type        = bool
  description = "Create private NAT gateways for non-routable subnets."
  default     = false
}

variable "azs" {
  type        = list(string)
  description = "List of AZs (3 for 3 AZ deployment)."
}
