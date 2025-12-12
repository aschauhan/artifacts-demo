variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID."
}

variable "nat_gateway_ids" {
  type        = list(string)
  description = "Public NAT Gateway IDs (aligned with private_subnet_ids)."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs."
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets."
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets."
}

variable "non_routable_subnet_ids" {
  type        = list(string)
  description = "Non-routable subnet IDs."
  default     = []
}

variable "non_routable_subnet_count" {
  type        = number
  description = "Number of non-routable subnets."
  default     = 0
}

variable "private_nat_gateway_ids" {
  type        = list(string)
  description = "Private NAT Gateway IDs (aligned with non-routable subnets)."
  default     = []
}

variable "name_prefix" {
  type        = string
  default     = "rtb"
}

variable "environment" {
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
