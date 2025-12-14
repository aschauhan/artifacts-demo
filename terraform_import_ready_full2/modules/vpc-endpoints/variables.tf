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

# --- New Optional VPC Endpoint Arguments ---

variable "auto_accept_endpoints" {
  description = "Whether to automatically accept the VPC endpoint connection."
  type        = bool
  default     = null # Use null so Terraform omits the argument if not set
}

variable "ip_address_type" {
  description = "The IP address type for the endpoint (ipv4, dualstack, or ipv6)."
  type        = string
  default     = null
}

variable "s3_gateway_policy" {
  description = "A JSON policy document for the S3 Gateway Endpoint. Defaults to full access if null."
  type        = string
  default     = null
}

variable "interface_endpoints_policy" {
  description = "A JSON policy document for all Interface Endpoints. Defaults to full access if null."
  type        = string
  default     = null
}

variable "default_private_dns_enabled" {
  description = "Whether to associate a private hosted zone for Interface Endpoints."
  type        = bool
  default     = true # Defaulting to true as is common practice for private endpoints
}

variable "interface_service_region" {
  description = "The AWS region of the VPC Endpoint Service for Interface Endpoints (if connecting cross-region)."
  type        = string
  default     = null
}

# DNS Options Block
variable "interface_dns_record_ip_type" {
  description = "The DNS records created for the endpoint (ipv4, dualstack, service-defined, or ipv6)."
  type        = string
  default     = null
}

variable "interface_private_dns_only_for_inbound_resolver_endpoint" {
  description = "Indicates whether to enable private DNS only for inbound endpoints."
  type        = bool
  default     = null
}