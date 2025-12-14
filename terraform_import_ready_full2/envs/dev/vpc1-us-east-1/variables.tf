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

# -------------------------------------------------------------------
# --- New Optional Variables for Subnet Module ---
# -------------------------------------------------------------------

variable "subnet_availability_zone_ids" {
  type        = list(string)
  description = "A list of Availability Zone IDs (e.g., use1-az1) to use instead of AZ names."
  default     = []
}

variable "public_subnet_ipv6_cidrs" {
  type        = list(string)
  description = "List of IPv6 CIDR blocks for public subnets."
  default     = []
}

variable "private_subnet_ipv6_cidrs" {
  type        = list(string)
  description = "List of IPv6 CIDR blocks for private subnets."
  default     = []
}

variable "nonroutable_subnet_ipv6_cidrs" {
  type        = list(string)
  description = "List of IPv6 CIDR blocks for non-routable subnets."
  default     = []
}

variable "subnet_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Specify true to indicate that network interfaces created in the subnet should be assigned an IPv6 address."
  default     = null
}

variable "subnet_customer_owned_ipv4_pool" {
  type        = string
  description = "The customer owned IPv4 address pool. Requires subnet_outpost_arn."
  default     = null
}

variable "subnet_enable_dns64" {
  type        = bool
  description = "Indicates whether DNS queries should return synthetic IPv6 addresses for IPv4-only destinations."
  default     = null
}

variable "subnet_enable_lni_at_device_index" {
  type        = number
  description = "Indicates the device position for local network interfaces in this subnet."
  default     = null
}

variable "subnet_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records."
  default     = null
}

variable "subnet_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS A records."
  default     = null
}

variable "subnet_ipv6_native" {
  type        = bool
  description = "Indicates whether to create an IPv6-only subnet."
  default     = null
}

variable "subnet_map_customer_owned_ip_on_launch" {
  type        = bool
  description = "Specify true to assign a customer owned IP address. Requires customer_owned_ipv4_pool and outpost_arn."
  default     = null
}

variable "subnet_outpost_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the Outpost."
  default     = null
}

variable "subnet_private_dns_hostname_type_on_launch" {
  type        = string
  description = "The type of hostnames to assign to instances in the subnet at launch (ip-name, resource-name)."
  default     = null
}


# -------------------------------------------------------------------
# --- Optional Variables for VPC Endpoints Module ---
# -------------------------------------------------------------------

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
  default     = false
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