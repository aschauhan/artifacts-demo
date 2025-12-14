variable "environment" {
  type        = string
  description = "Environment name, e.g. dev."
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

variable "security_groups" {
  description = "List of security groups passed from tfvars"
  type        = any
}


variable "ingress_rules" {
  description = "Flattened ingress rules for SG module"
  type        = any
}

variable "egress_rules" {
  description = "Flattened egress rules for SG module"
  type        = any
}

variable "nacl_config" {
  type = any
}

# --- New Optional Variables for VPC Endpoints Module ---

variable "vpc_endpoints_auto_accept" {
  description = "Whether to automatically accept the VPC endpoint connection."
  type        = bool
  default     = null
}

variable "vpc_endpoints_ip_address_type" {
  description = "The IP address type for the endpoint (ipv4, dualstack, or ipv6)."
  type        = string
  default     = null
}

variable "vpc_endpoints_s3_gateway_policy" {
  description = "A JSON policy document for the S3 Gateway Endpoint."
  type        = string
  default     = null
}

variable "vpc_endpoints_interface_endpoints_policy" {
  description = "A JSON policy document for all Interface Endpoints."
  type        = string
  default     = null
}

variable "vpc_endpoints_default_private_dns_enabled" {
  description = "Whether to associate a private hosted zone for Interface Endpoints."
  type        = bool
  default     = true
}

variable "vpc_endpoints_interface_service_region" {
  description = "The AWS region of the VPC Endpoint Service for Interface Endpoints (if connecting cross-region)."
  type        = string
  default     = null
}

variable "vpc_endpoints_interface_dns_record_ip_type" {
  description = "The DNS records created for the interface endpoints (ipv4, dualstack, service-defined, or ipv6)."
  type        = string
  default     = null
}

variable "vpc_endpoints_interface_private_dns_only_for_inbound_resolver_endpoint" {
  description = "Indicates whether to enable private DNS only for inbound endpoints."
  type        = bool
  default     = null
}