variable "security_groups" {
  description = "List of security groups"
  type = list(object({
    name        = string
    description = string
    vpc_id      = string
    tags        = map(string)

    ingress_rules = optional(list(object({
      description  = string
      from_port    = number
      to_port      = number
      protocol     = string
      cidr_blocks  = list(string)
    })), [])

    egress_rules = optional(list(object({
      description  = string
      from_port    = number
      to_port      = number
      protocol     = string
      cidr_blocks  = list(string)
    })), [])
  }))
}

variable "ingress_rules" {
  description = "Flattened ingress rules for all SGs"
  type        = any
}

variable "egress_rules" {
  description = "Flattened egress rules for all SGs"
  type        = any
}
