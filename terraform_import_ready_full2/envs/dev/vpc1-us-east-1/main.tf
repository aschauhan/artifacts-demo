# -----------------------------------------------------------
# 1. TERRAFORM & PROVIDER CONFIGURATION
# -----------------------------------------------------------

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Data lookup to retrieve the Availability Zone for all combined subnets.
data "aws_subnet" "all_interface_subnets" {
  # Use count to iterate over the dynamic list of subnet IDs
  count = length(local.interface_endpoint_subnet_ids) 
  id    = local.interface_endpoint_subnet_ids[count.index]
}

locals {
  base_tags = {
    Project = "my-project"
  }
  # Combine private and non-routable subnets for interface endpoints
  interface_endpoint_subnet_ids = concat(module.private_subnets.subnet_ids, module.non_routable_subnets.subnet_ids)
  
  # Group subnets by AZ and select only one subnet ID per AZ to satisfy AWS requirement.
  # Now iterating over the list of data resources created by the 'count' meta-argument.
  az_to_subnet_groups = { 
    for s in data.aws_subnet.all_interface_subnets : s.availability_zone => s.id... 
  }
  filtered_interface_subnet_ids = [for az, ids in local.az_to_subnet_groups : ids[0]]

  # Combine route table IDs for private/non-routable to attach S3 gateway endpoint
  # NOTE: Adjust the output names (e.g., '.private_route_table_ids') if your 'route_tables' module uses different names.
  combined_route_table_ids = concat(
    module.route_tables.private_route_table_ids,
    module.route_tables.non_routable_route_table_ids
  )
}

module "vpc" {
  source = "../../../modules/vpc"

  cidr_block                   = var.vpc_cidr
  additional_cidrs             = var.additional_cidrs

  instance_tenancy             = "default"
  ipv4_ipam_pool_id            = null
  ipv4_netmask_length          = null
  ipv6_cidr_block              = null
  ipv6_ipam_pool_id            = null
  ipv6_netmask_length          = null
  ipv6_cidr_block_network_border_group = null
  assign_generated_ipv6_cidr_block     = false
  enable_dns_support           = true
  enable_dns_hostnames         = true
  enable_network_address_usage_metrics = false

  environment = var.environment
  tags        = local.base_tags
  
}

# -------------------------------------------------------------
# 1. Public Subnets Module Call
# -------------------------------------------------------------
module "public_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.public_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = true
  name_prefix        = "public"
  environment        = var.environment
  tags               = local.base_tags
  depends_on = [module.vpc]
  
  # --- New Optional Arguments Mapping ---
  availability_zone_ids                        = var.subnet_availability_zone_ids # ADDED
  ipv6_cidr_blocks                             = var.public_subnet_ipv6_cidrs
  assign_ipv6_address_on_creation              = var.subnet_assign_ipv6_address_on_creation
  customer_owned_ipv4_pool                     = var.subnet_customer_owned_ipv4_pool
  enable_dns64                                 = var.subnet_enable_dns64
  enable_lni_at_device_index                   = var.subnet_enable_lni_at_device_index
  enable_resource_name_dns_aaaa_record_on_launch = var.subnet_enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.subnet_enable_resource_name_dns_a_record_on_launch
  ipv6_native                                  = var.subnet_ipv6_native
  map_customer_owned_ip_on_launch              = var.subnet_map_customer_owned_ip_on_launch
  outpost_arn                                  = var.subnet_outpost_arn
  private_dns_hostname_type_on_launch          = var.subnet_private_dns_hostname_type_on_launch
}

# -------------------------------------------------------------
# 2. Private Subnets Module Call
# -------------------------------------------------------------
module "private_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.private_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = false
  name_prefix        = "private"
  environment        = var.environment
  tags               = local.base_tags
  depends_on = [module.vpc]

  # --- New Optional Arguments Mapping ---
  availability_zone_ids                        = var.subnet_availability_zone_ids # ADDED
  ipv6_cidr_blocks                             = var.private_subnet_ipv6_cidrs
  assign_ipv6_address_on_creation              = var.subnet_assign_ipv6_address_on_creation
  customer_owned_ipv4_pool                     = var.subnet_customer_owned_ipv4_pool
  enable_dns64                                 = var.subnet_enable_dns64
  enable_lni_at_device_index                   = var.subnet_enable_lni_at_device_index
  enable_resource_name_dns_aaaa_record_on_launch = var.subnet_enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.subnet_enable_resource_name_dns_a_record_on_launch
  ipv6_native                                  = var.subnet_ipv6_native
  map_customer_owned_ip_on_launch              = var.subnet_map_customer_owned_ip_on_launch
  outpost_arn                                  = var.subnet_outpost_arn
  private_dns_hostname_type_on_launch          = var.subnet_private_dns_hostname_type_on_launch
}

# -------------------------------------------------------------
# 3. Non-Routable Subnets Module Call
# -------------------------------------------------------------
module "non_routable_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.nonroutable_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = false
  name_prefix        = "non-routable"
  environment        = var.environment
  tags               = local.base_tags
  depends_on = [module.vpc]

  # --- New Optional Arguments Mapping ---
  availability_zone_ids                        = var.subnet_availability_zone_ids # ADDED
  ipv6_cidr_blocks                             = var.nonroutable_subnet_ipv6_cidrs
  assign_ipv6_address_on_creation              = var.subnet_assign_ipv6_address_on_creation
  customer_owned_ipv4_pool                     = var.subnet_customer_owned_ipv4_pool
  enable_dns64                                 = var.subnet_enable_dns64
  enable_lni_at_device_index                   = var.subnet_enable_lni_at_device_index
  enable_resource_name_dns_aaaa_record_on_launch = var.subnet_enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.subnet_enable_resource_name_dns_a_record_on_launch
  ipv6_native                                  = var.subnet_ipv6_native
  map_customer_owned_ip_on_launch              = var.subnet_map_customer_owned_ip_on_launch
  outpost_arn                                  = var.subnet_outpost_arn
  private_dns_hostname_type_on_launch          = var.subnet_private_dns_hostname_type_on_launch
}

module "gateways" {
  source = "../../../modules/gateways"

  vpc_id = module.vpc.vpc_id

  enable_igw = true

  nat_subnet_ids    = module.public_subnets.subnet_ids
  nat_gateway_count = length(var.public_subnet_cidrs)

  private_nat_subnet_ids    = module.non_routable_subnets.subnet_ids
  private_nat_gateway_count = var.enable_private_nat_gateway ? length(var.nonroutable_subnet_cidrs) : 0

  environment = var.environment
  tags        = local.base_tags
  depends_on = [module.vpc]
}

module "route_tables" {
  source = "../../../modules/route-tables"

  vpc_id                      = module.vpc.vpc_id
  igw_id                      = module.gateways.igw_id
  nat_gateway_ids             = module.gateways.nat_gateway_ids
  public_subnet_ids           = module.public_subnets.subnet_ids
  private_subnet_ids          = module.private_subnets.subnet_ids
  public_subnet_count         = length(var.public_subnet_cidrs)
  private_subnet_count        = length(var.private_subnet_cidrs)

  non_routable_subnet_ids     = module.non_routable_subnets.subnet_ids
  non_routable_subnet_count   = length(var.nonroutable_subnet_cidrs)
  private_nat_gateway_ids     = module.gateways.private_nat_gateway_ids

  environment = var.environment
  tags        = local.base_tags
}

#dhcp options

module "dhcp_options" {
  source = "../../../modules/dhcp-options"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = local.base_tags

  domain_name           = "example.internal"
  domain_name_servers   = ["AmazonProvidedDNS"]
  ntp_servers           = []
  netbios_name_servers  = []
  netbios_node_type     = null
}

########################################
#SG
########################################
########################################
# Merge SGs from tfvars with dynamic VPC ID
########################################
locals {
  sg_with_vpc = [
    for sg in var.security_groups : merge(
      sg,
      {
        vpc_id = module.vpc.vpc_id
        # FIX: Explicitly merge base tags and set the Name tag for AWS Console visibility.
        # This relies on the internal module being able to consume a 'tags' attribute.
        tags = merge(
          local.base_tags,
          {
            Name = format("%s-%s", var.environment, sg.name)
          }
        )
      }
    )
  ]
}

########################################
# Security Group Module Call
########################################
module "security_groups" {
  source = "../../../modules/security-group"

  security_groups = local.sg_with_vpc
  ingress_rules   = var.ingress_rules
  egress_rules    = var.egress_rules
  
  # REMOVED unsupported arguments: environment and tags
}

#######################################
# NACL
###################################
locals {
  nacl_config = [
    for nacl in var.nacl_config : merge(
      nacl,
      {
        vpc_id = module.vpc.vpc_id

        subnet_ids = (
          nacl.name == "public-nacl" ?
          module.public_subnets.subnet_ids :
          concat(module.private_subnets.subnet_ids, module.non_routable_subnets.subnet_ids)
        )
      }
    )
  ]
}

module "nacls" {
  source      = "../../../modules/nacl"
  nacl_config = local.nacl_config
}

######## End of NACL ######## 

########################################
# VPC Endpoints Module Call (NEW)
########################################
module "vpc_endpoints" {
  source = "../../../modules/vpc-endpoints" # Assuming the module is placed here

  vpc_id                      = module.vpc.vpc_id
  vpc_cidr_block              = var.vpc_cidr # Pass the VPC CIDR for SG rules
  region                      = var.region
  environment                 = var.environment
  tags                        = local.base_tags
  
  # List of private and non-routable route table IDs for S3 Gateway
  private_route_table_ids     = local.combined_route_table_ids
  
  # PASS THE FILTERED LIST to ensure only one subnet per AZ is used
  interface_subnet_ids        = local.filtered_interface_subnet_ids

  # --- New Optional Arguments Passed from Root Variables ---
  auto_accept_endpoints       = var.vpc_endpoints_auto_accept
  ip_address_type             = var.vpc_endpoints_ip_address_type
  s3_gateway_policy           = var.vpc_endpoints_s3_gateway_policy
  interface_endpoints_policy  = var.vpc_endpoints_interface_endpoints_policy
  default_private_dns_enabled = var.vpc_endpoints_default_private_dns_enabled
  interface_service_region    = var.vpc_endpoints_interface_service_region
  interface_dns_record_ip_type = var.vpc_endpoints_interface_dns_record_ip_type
  interface_private_dns_only_for_inbound_resolver_endpoint = var.vpc_endpoints_interface_private_dns_only_for_inbound_resolver_endpoint

  # Endpoints depend on VPC, Subnets, and Route Tables
  depends_on = [
    module.vpc,
    module.private_subnets,
    module.non_routable_subnets,
    module.route_tables
  ]
}