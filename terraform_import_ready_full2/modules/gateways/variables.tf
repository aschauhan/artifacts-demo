variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "enable_igw" {
  type        = bool
  default     = true
}

variable "nat_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets for public NAT gateways (typically public subnets)."
}

variable "nat_gateway_count" {
  type        = number
  default     = 0
  description = "Number of public NAT gateways."
}

variable "private_nat_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets for private NAT gateways (non-routable subnets)."
}

variable "private_nat_gateway_count" {
  type        = number
  default     = 0
  description = "Number of private NAT gateways."
}

variable "name_prefix" {
  type        = string
  default     = "gw"
}

variable "environment" {
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
