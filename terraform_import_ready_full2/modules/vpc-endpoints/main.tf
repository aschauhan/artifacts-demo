# This file contains ONLY the resources for VPC Endpoints and a corresponding Security Group.
# All references to other modules (vpc, subnets, route_tables, etc.) have been removed.

# --- Input Constraint Note ---
# IMPORTANT: The list provided to 'var.interface_subnet_ids' MUST contain only one subnet ID 
# per Availability Zone to avoid the AWS API error 'DuplicateSubnetsInSameZone'. 
# The dynamic filtering logic was removed as it failed during the Terraform plan phase.
# -----------------------------


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
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # Optional Arguments
  auto_accept     = var.auto_accept_endpoints
  policy          = var.s3_gateway_policy
  ip_address_type = var.ip_address_type

  # Crucial: Attaches the S3 Gateway to the Private and Non-Routable Route Tables only.
  route_table_ids = var.private_route_table_ids 

  tags = merge(var.tags, {
    Name = format("%s-s3-gateway-endpoint", var.environment)
  })
}

#
# 2. Interface Endpoints (EC2 and SSM/Messaging) - Using SEPARATE RESOURCES
#

# Local for checking if dns_options should be included (for all interface endpoints)
locals {
  should_include_dns_options = (
    var.interface_dns_record_ip_type != null ||
    var.interface_private_dns_only_for_inbound_resolver_endpoint != null
  )
}

resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  # Required Interface Arguments
  subnet_ids          = var.interface_subnet_ids 
  security_group_ids  = [aws_security_group.interface_endpoints_sg.id]

  # Optional Arguments
  auto_accept         = var.auto_accept_endpoints
  policy              = var.interface_endpoints_policy
  ip_address_type     = var.ip_address_type
  private_dns_enabled = var.default_private_dns_enabled
  service_region      = var.interface_service_region

  dynamic "dns_options" {
    # Only include the block if any advanced DNS options are provided
    for_each = local.should_include_dns_options ? [1] : []
    content {
      dns_record_ip_type                  = var.interface_dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = var.interface_private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = merge(var.tags, {
    Name = format("%s-ec2-interface-endpoint", var.environment)
  })
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  # Required Interface Arguments
  subnet_ids          = var.interface_subnet_ids 
  security_group_ids  = [aws_security_group.interface_endpoints_sg.id]
  
  # Optional Arguments
  auto_accept         = var.auto_accept_endpoints
  policy              = var.interface_endpoints_policy
  ip_address_type     = var.ip_address_type
  private_dns_enabled = var.default_private_dns_enabled
  service_region      = var.interface_service_region
  
  dynamic "dns_options" {
    for_each = local.should_include_dns_options ? [1] : []
    content {
      dns_record_ip_type                  = var.interface_dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = var.interface_private_dns_only_for_inbound_resolver_endpoint
    }
  }

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

  # Required Interface Arguments
  subnet_ids          = var.interface_subnet_ids 
  security_group_ids  = [aws_security_group.interface_endpoints_sg.id]
  
  # Optional Arguments
  auto_accept         = var.auto_accept_endpoints
  policy              = var.interface_endpoints_policy
  ip_address_type     = var.ip_address_type
  private_dns_enabled = var.default_private_dns_enabled
  service_region      = var.interface_service_region

  dynamic "dns_options" {
    for_each = local.should_include_dns_options ? [1] : []
    content {
      dns_record_ip_type                  = var.interface_dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = var.interface_private_dns_only_for_inbound_resolver_endpoint
    }
  }

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

  # Required Interface Arguments
  subnet_ids          = var.interface_subnet_ids 
  security_group_ids  = [aws_security_group.interface_endpoints_sg.id]
  
  # Optional Arguments
  auto_accept         = var.auto_accept_endpoints
  policy              = var.interface_endpoints_policy
  ip_address_type     = var.ip_address_type
  private_dns_enabled = var.default_private_dns_enabled
  service_region      = var.interface_service_region
  
  dynamic "dns_options" {
    for_each = local.should_include_dns_options ? [1] : []
    content {
      dns_record_ip_type                  = var.interface_dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = var.interface_private_dns_only_for_inbound_resolver_endpoint
    }
  }

  # Ensure EC2Messages waits for SSMMessages to finish
  depends_on = [aws_vpc_endpoint.ssmmessages_endpoint]

  tags = merge(var.tags, {
    Name = format("%s-ec2messages-interface-endpoint", var.environment)
  })
}