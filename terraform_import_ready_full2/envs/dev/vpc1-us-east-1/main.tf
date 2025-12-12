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

locals {
  base_tags = {
    Project = "my-project"
  }
  # Combine private and non-routable subnets for interface endpoints
  interface_endpoint_subnet_ids = concat(module.private_subnets.subnet_ids, module.non_routable_subnets.subnet_ids)

  # Combine route table IDs for private/non-routable to attach S3 gateway endpoint
  # NOTE: Adjust the output names (e.g., '.private_route_table_ids') if your 'route_tables' module uses different names.
  combined_route_table_ids = concat(
    module.route_tables.private_route_table_ids,
    module.route_tables.non_routable_route_table_ids
  )
}

module "vpc" {
  source = "../../../modules/vpc"

  cidr_block       = var.vpc_cidr
  additional_cidrs = var.additional_cidrs

  instance_tenancy                     = "default"
  ipv4_ipam_pool_id                    = null
  ipv4_netmask_length                  = null
  ipv6_cidr_block                      = null
  ipv6_ipam_pool_id                    = null
  ipv6_netmask_length                  = null
  ipv6_cidr_block_network_border_group = null
  assign_generated_ipv6_cidr_block     = false
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = false

  environment = var.environment
  tags        = local.base_tags

}

module "public_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.public_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = true
  name_prefix        = "public"
  environment        = var.environment
  tags               = local.base_tags
  depends_on         = [module.vpc]
}

module "private_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.private_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = false
  name_prefix        = "private"
  environment        = var.environment
  tags               = local.base_tags
  depends_on         = [module.vpc]
}

module "non_routable_subnets" {
  source = "../../../modules/subnets"

  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = var.nonroutable_subnet_cidrs
  availability_zones = var.azs
  map_public_ip      = false
  name_prefix        = "non-routable"
  environment        = var.environment
  tags               = local.base_tags
  depends_on         = [module.vpc]
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
  depends_on  = [module.vpc]
}

module "route_tables" {
  source = "../../../modules/route-tables"

  vpc_id               = module.vpc.vpc_id
  igw_id               = module.gateways.igw_id
  nat_gateway_ids      = module.gateways.nat_gateway_ids
  public_subnet_ids    = module.public_subnets.subnet_ids
  private_subnet_ids   = module.private_subnets.subnet_ids
  public_subnet_count  = length(var.public_subnet_cidrs)
  private_subnet_count = length(var.private_subnet_cidrs)

  non_routable_subnet_ids   = module.non_routable_subnets.subnet_ids
  non_routable_subnet_count = length(var.nonroutable_subnet_cidrs)
  private_nat_gateway_ids   = module.gateways.private_nat_gateway_ids

  environment = var.environment
  tags        = local.base_tags
}

#dhcp options

module "dhcp_options" {
  source = "../../../modules/dhcp-options"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  tags        = local.base_tags

  domain_name          = "example.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]
  ntp_servers          = []
  netbios_name_servers = []
  netbios_node_type    = null
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

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr # Pass the VPC CIDR for SG rules
  region         = var.region
  environment    = var.environment
  tags           = local.base_tags

  # List of private and non-routable route table IDs for S3 Gateway
  private_route_table_ids = local.combined_route_table_ids

  # List of private and non-routable subnet IDs for Interface Endpoints
  interface_subnet_ids = local.interface_endpoint_subnet_ids

  # Endpoints depend on VPC, Subnets, and Route Tables
  depends_on = [
    module.vpc,
    module.private_subnets,
    module.non_routable_subnets,
    module.route_tables
  ]
}