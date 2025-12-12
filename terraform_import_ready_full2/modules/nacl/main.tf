########################################
# Create NACLs (index based)
########################################
resource "aws_network_acl" "this" {
  count = length(var.nacl_config)

  vpc_id = var.nacl_config[count.index].vpc_id
#   tags   = merge(var.nacl_config[count.index].tags, {
#     Name = var.nacl_config[count.index].name
#   }
  tags = merge(
  { Name = var.nacl_config[count.index].name },
  var.nacl_config[count.index].tags
)
  
}

########################################
# Associate Subnets
########################################
resource "aws_network_acl_association" "assoc" {
  count = sum([for n in var.nacl_config : length(n.subnet_ids)])

  network_acl_id = aws_network_acl.this[
    index(
      [for n in var.nacl_config : n.name],
      flatten([for n in var.nacl_config : [for s in n.subnet_ids : n.name]])[count.index]
    )
  ].id

  subnet_id = flatten([for n in var.nacl_config : n.subnet_ids])[count.index]
}

########################################
# Ingress Rules
########################################
resource "aws_network_acl_rule" "ingress" {
  count = sum([for n in var.nacl_config : length(n.ingress)])

  network_acl_id = aws_network_acl.this[
    index(
      [for n in var.nacl_config : n.name],
      flatten([for n in var.nacl_config : [for r in n.ingress : n.name]])[count.index]
    )
  ].id

  rule_number     = flatten([for n in var.nacl_config : [for r in n.ingress : r.rule_no]])[count.index]
  rule_action     = flatten([for n in var.nacl_config : [for r in n.ingress : r.action]])[count.index]
  protocol        = flatten([for n in var.nacl_config : [for r in n.ingress : r.protocol]])[count.index]
  from_port       = flatten([for n in var.nacl_config : [for r in n.ingress : r.from_port]])[count.index]
  to_port         = flatten([for n in var.nacl_config : [for r in n.ingress : r.to_port]])[count.index]
  cidr_block      = flatten([for n in var.nacl_config : [for r in n.ingress : lookup(r, "cidr_block", null)]])[count.index]
  ipv6_cidr_block = flatten([for n in var.nacl_config : [for r in n.ingress : lookup(r, "ipv6_cidr_block", null)]])[count.index]
  icmp_type       = flatten([for n in var.nacl_config : [for r in n.ingress : lookup(r, "icmp_type", 0)]])[count.index]
  icmp_code       = flatten([for n in var.nacl_config : [for r in n.ingress : lookup(r, "icmp_code", 0)]])[count.index]

  egress = false
}

########################################
# Egress Rules
########################################
resource "aws_network_acl_rule" "egress" {
  count = sum([for n in var.nacl_config : length(n.egress)])

  network_acl_id = aws_network_acl.this[
    index(
      [for n in var.nacl_config : n.name],
      flatten([for n in var.nacl_config : [for r in n.egress : n.name]])[count.index]
    )
  ].id

  rule_number     = flatten([for n in var.nacl_config : [for r in n.egress : r.rule_no]])[count.index]
  rule_action     = flatten([for n in var.nacl_config : [for r in n.egress : r.action]])[count.index]
  protocol        = flatten([for n in var.nacl_config : [for r in n.egress : r.protocol]])[count.index]
  from_port       = flatten([for n in var.nacl_config : [for r in n.egress : r.from_port]])[count.index]
  to_port         = flatten([for n in var.nacl_config : [for r in n.egress : r.to_port]])[count.index]
  cidr_block      = flatten([for n in var.nacl_config : [for r in n.egress : lookup(r, "cidr_block", null)]])[count.index]
  ipv6_cidr_block = flatten([for n in var.nacl_config : [for r in n.egress : lookup(r, "ipv6_cidr_block", null)]])[count.index]
  icmp_type       = flatten([for n in var.nacl_config : [for r in n.egress : lookup(r, "icmp_type", 0)]])[count.index]
  icmp_code       = flatten([for n in var.nacl_config : [for r in n.egress : lookup(r, "icmp_code", 0)]])[count.index]

  egress = true
}
