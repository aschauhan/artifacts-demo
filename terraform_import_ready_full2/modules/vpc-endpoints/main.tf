# This file contains ONLY the resources for VPC Endpoints and a corresponding Security Group.
# All references to other modules (vpc, subnets, route_tables, etc.) have been removed.

# --- Data Lookups and Filtering for Subnets ---
# FIX: Subnet filtering to ensure only one subnet per Availability Zone is used,
# resolving the AWS API error "DuplicateSubnetsInSameZone" and the Terraform error "Duplicate object key".
data "aws_subnet" "interface_subnets" {
  for_each = toset(var.interface_subnet_ids)
  id       = each.key
}

locals {
  # FIX: Use the grouping syntax (=> value...) to collect all subnet IDs per AZ.
  az_to_subnet_groups = { for s in data.aws_subnet.interface_subnets : s.availability_zone => s.id... }

  # Now, extract the first subnet ID from each list, resulting in a clean, filtered list
  # where there is exactly one subnet ID per unique AZ.
  unique_interface_subnet_ids = [for az, ids in local.az_to_subnet_groups : ids[0]]
}
# ---------------------------------------------


#
# Dedicated Security Group for Interface Endpoints (SSM, EC2)
#
resource "aws_security_group" "interface_endpoints_sg" {
  name        = format("%s-vpc-endpoints-sg", var.environment)
  description = "Security Group for VPC Interface Endpoints (SSM, EC2)"
  vpc_id      = var.vpc_id

  # Ingress: Allow traffic from the entire VPC CIDR range (or specific private subnets)
  ingress {
    description = "Allow all inbound TCP from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Egress: Allow all outbound traffic (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = format("%s-vpc-endpoints-sg", var.environment)
  })
}

#
# 1. S3 Gateway Endpoint
#
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # Crucial: Attaches the S3 Gateway to the Private and Non-Routable Route Tables only.
  route_table_ids = var.private_route_table_ids 

  tags = merge(var.tags, {
    Name = format("%s-s3-gateway-endpoint", var.environment)
  })
}

#
# 2. Interface Endpoints (EC2 and SSM/Messaging) - Using SEPARATE RESOURCES and a dependency chain
# The subnets are now filtered above using the 'unique_interface_subnet_ids' local.

resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  # Use the filtered subnet list
  subnet_ids             = local.unique_interface_subnet_ids 
  security_group_ids     = [aws_security_group.interface_endpoints_sg.id]
  private_dns_enabled    = true

  tags = merge(var.tags, {
    Name = format("%s-ec2-interface-endpoint", var.environment)
  })
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  # Use the filtered subnet list
  subnet_ids             = local.unique_interface_subnet_ids 
  security_group_ids     = [aws_security_group.interface_endpoints_sg.id]
  private_dns_enabled    = true
  
  # Ensure SSM waits for EC2 to finish creating its ENIs
  depends_on = [aws_vpc_endpoint.ec2_endpoint]

  tags = merge(var.tags, {
    Name = format("%s-ssm-interface-endpoint", var.environment)
  })
}

resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  # Use the filtered subnet list
  subnet_ids             = local.unique_interface_subnet_ids 
  security_group_ids     = [aws_security_group.interface_endpoints_sg.id]
  private_dns_enabled    = true

  # Ensure SSMMessages waits for SSM to finish
  depends_on = [aws_vpc_endpoint.ssm_endpoint]

  tags = merge(var.tags, {
    Name = format("%s-ssmmessages-interface-endpoint", var.environment)
  })
}

resource "aws_vpc_endpoint" "ec2messages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  # Use the filtered subnet list
  subnet_ids             = local.unique_interface_subnet_ids 
  security_group_ids     = [aws_security_group.interface_endpoints_sg.id]
  private_dns_enabled    = true

  # Ensure EC2Messages waits for SSMMessages to finish
  depends_on = [aws_vpc_endpoint.ssmmessages_endpoint]

  tags = merge(var.tags, {
    Name = format("%s-ec2messages-interface-endpoint", var.environment)
  })
}