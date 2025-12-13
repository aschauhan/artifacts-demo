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
# The subnet list is now expected to be correctly pre-filtered by the calling module.

resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  # Using the input variable directly (must be filtered outside this module)
  subnet_ids             = var.interface_subnet_ids 
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

  # Using the input variable directly (must be filtered outside this module)
  subnet_ids             = var.interface_subnet_ids 
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

  # Using the input variable directly (must be filtered outside this module)
  subnet_ids             = var.interface_subnet_ids 
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

  # Using the input variable directly (must be filtered outside this module)
  subnet_ids             = var.interface_subnet_ids 
  security_group_ids     = [aws_security_group.interface_endpoints_sg.id]
  private_dns_enabled    = true

  # Ensure EC2Messages waits for SSMMessages to finish
  depends_on = [aws_vpc_endpoint.ssmmessages_endpoint]

  tags = merge(var.tags, {
    Name = format("%s-ec2messages-interface-endpoint", var.environment)
  })
}