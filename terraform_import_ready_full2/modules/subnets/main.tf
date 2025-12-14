# This module creates a collection of subnets in the specified availability zones,
# using 'for_each' for robust mapping of CIDRs and AZs.

locals {
  tags_final = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_subnet" "this" {
  for_each = {
    # Loop over IPv4 CIDRs. We prioritize AZ IDs if provided, otherwise use AZ names.
    for idx, cidr in var.subnet_cidrs :
    tostring(idx) => {
      cidr      = cidr
      # If AZ IDs are provided, use them and set AZ name to null, otherwise use AZ names.
      az_name   = length(var.availability_zone_ids) > 0 ? null : var.availability_zones[idx]
      az_id     = length(var.availability_zone_ids) > 0 ? var.availability_zone_ids[idx] : null
      # Safely access the IPv6 CIDR, or set to null if the list is empty or the index is out of bounds
      ipv6_cidr = idx < length(var.ipv6_cidr_blocks) ? var.ipv6_cidr_blocks[idx] : null
    }
  }

  vpc_id                        = var.vpc_id
  cidr_block                    = each.value.cidr
  ipv6_cidr_block               = each.value.ipv6_cidr # Conditionally set to null or a CIDR
  
  # Only one of these can be set based on the for_each logic above
  availability_zone             = each.value.az_name
  availability_zone_id          = each.value.az_id
  
  map_public_ip_on_launch       = var.map_public_ip

  # --- Optional Subnet Arguments ---
  assign_ipv6_address_on_creation       = var.assign_ipv6_address_on_creation
  customer_owned_ipv4_pool              = var.customer_owned_ipv4_pool
  enable_dns64                          = var.enable_dns64
  enable_lni_at_device_index            = var.enable_lni_at_device_index
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.enable_resource_name_dns_a_record_on_launch
  ipv6_native                           = var.ipv6_native
  map_customer_owned_ip_on_launch       = var.map_customer_owned_ip_on_launch
  outpost_arn                           = var.outpost_arn
  private_dns_hostname_type_on_launch   = var.private_dns_hostname_type_on_launch

  tags = merge(
    local.tags_final,
    {
      # Name format using the index for uniqueness within the prefix
      Name = format("%s-%s", var.name_prefix, each.key)
    }
  )
}