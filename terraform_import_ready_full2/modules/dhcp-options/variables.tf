variable "environment" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate the DHCP options with."
}

variable "domain_name" {
  type    = string
  default = null
}

variable "domain_name_servers" {
  type    = list(string)
  default = ["AmazonProvidedDNS"]
}

variable "ntp_servers" {
  type    = list(string)
  default = []
}

variable "netbios_name_servers" {
  type    = list(string)
  default = []
}

variable "netbios_node_type" {
  type    = number
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
