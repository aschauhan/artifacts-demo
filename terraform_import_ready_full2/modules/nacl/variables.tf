variable "nacl_config" {
  description = "List of NACL objects"
  type = list(object({
    name       = string
    region     = optional(string)
    vpc_id     = string
    subnet_ids = list(string)
    tags       = optional(map(string), {})

    ingress = optional(list(object({
      rule_no        = number
      action         = string
      protocol       = string
      from_port      = number
      to_port        = number
      cidr_block     = optional(string)
      ipv6_cidr_block = optional(string)
      icmp_type      = optional(number, 0)
      icmp_code      = optional(number, 0)
    })), [])

    egress = optional(list(object({
      rule_no        = number
      action         = string
      protocol       = string
      from_port      = number
      to_port        = number
      cidr_block     = optional(string)
      ipv6_cidr_block = optional(string)
      icmp_type      = optional(number, 0)
      icmp_code      = optional(number, 0)
    })), [])
  }))
}
