# Required Inputs
variable "vpc_id" {
  description = "The VPC ID to which the subnets will belong."
  type        = string
}

variable "subnet_cidrs" {
  description = "A list of IPv4 CIDR blocks for the subnets (one per AZ)."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of Availability Zone names (must match the number of CIDRs)."
  type        = list(string)
}

variable "availability_zone_ids" {
  description = "A list of Availability Zone IDs (e.g., use1-az1). Takes precedence over availability_zones if provided."
  type        = list(string)
  default     = []
}

variable "map_public_ip" {
  description = "Controls whether to automatically assign a public IPv4 address to instances launched into the subnet."
  type        = bool
}

variable "name_prefix" {
  description = "Prefix for the Name tag of the subnets (e.g., 'public', 'private')."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., 'dev', 'prod')."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the subnets."
  type        = map(string)
  default     = {}
}

# --- Optional Subnet Arguments (New Features) ---

variable "ipv6_cidr_blocks" {
  description = "A list of IPv6 CIDR blocks for the subnets (optional)."
  type        = list(string)
  default     = []
}

variable "assign_ipv6_address_on_creation" {
  type        = bool
  description = "Specify true to indicate that network interfaces created in the subnet should be assigned an IPv6 address."
  default     = null
}

variable "customer_owned_ipv4_pool" {
  type        = string
  description = "The customer owned IPv4 address pool. Requires outpost_arn."
  default     = null
}

variable "enable_dns64" {
  type        = bool
  description = "Indicates whether DNS queries should return synthetic IPv6 addresses for IPv4-only destinations."
  default     = null
}

variable "enable_lni_at_device_index" {
  type        = number
  description = "Indicates the device position for local network interfaces in this subnet."
  default     = null
}

variable "enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records."
  default     = null
}

variable "enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS A records."
  default     = null
}

variable "ipv6_native" {
  type        = bool
  description = "Indicates whether to create an IPv6-only subnet."
  default     = null
}

variable "map_customer_owned_ip_on_launch" {
  type        = bool
  description = "Specify true to assign a customer owned IP address. Requires customer_owned_ipv4_pool and outpost_arn."
  default     = null
}

variable "outpost_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the Outpost."
  default     = null
}

variable "private_dns_hostname_type_on_launch" {
  type        = string
  description = "The type of hostnames to assign to instances in the subnet at launch (ip-name, resource-name)."
  default     = null
}