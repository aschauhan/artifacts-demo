environment = "dev"
region      = "us-east-1"

vpc_cidr = "10.65.0.0/24"

additional_cidrs = [
  "100.65.0.0/20",
  "100.64.0.0/24",
]

public_subnet_cidrs = [
  "100.65.0.0/26",
  "100.65.0.64/26",
  "100.65.0.128/26",
]

private_subnet_cidrs = [
  "10.65.0.0/28",
  "10.65.0.16/28",
  "10.65.0.32/28",
]

nonroutable_subnet_cidrs = [
  "100.64.0.0/28",
  "100.64.0.16/28",
  "100.64.0.32/28",
]

enable_private_nat_gateway = true

azs = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
]

security_groups = [
  {
    name        = "nat-forward-sg"
    description = "Allow NAT forwarding"
    tags = {
      Environment = "dev"
    }
  }
]

ingress_rules = [
  {
    sg_name     = "nat-forward-sg"
    description = "Allow all incoming traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

egress_rules = [
  {
    sg_name     = "nat-forward-sg"
    description = "Allow forwarding to private NAT Gateway range"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  },
  {
    sg_name     = "nat-forward-sg"
    description = "Allow outbound internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# END Security Group

nacl_config = [
  {
    name = "public-nacl"
    tags = { Environment = "dev" }

    ingress = [
      {
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        cidr_block = "0.0.0.0/0"
      }
    ]

    egress = [
      {
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        cidr_block = "0.0.0.0/0"
      }
    ]
  },

  {
    name = "private-nacl"
    tags = { Environment = "dev" }

    ingress = [
      {
        rule_no    = 110
        action     = "allow"
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        cidr_block = "10.0.0.0/8"
      }
    ]

    egress = [
      {
        rule_no    = 110
        action     = "allow"
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        cidr_block = "0.0.0.0/0"
      }
    ]
  }
]


############ END NACL ######## 
