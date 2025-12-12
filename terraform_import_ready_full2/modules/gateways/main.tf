locals {
  tags_final = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_internet_gateway" "igw" {
  count = var.enable_igw ? 1 : 0

  vpc_id = var.vpc_id

  tags = merge(local.tags_final, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_eip" "nat" {
  count = var.nat_gateway_count

  tags = merge(local.tags_final, {
    Name = "public-nat-eip-${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.nat_gateway_count

  subnet_id     = var.nat_subnet_ids[count.index]
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(local.tags_final, {
    Name = "public-nat-${count.index}"
  })
}

resource "aws_nat_gateway" "private_nat_gw" {
  count             = var.private_nat_gateway_count
  subnet_id         = var.private_nat_subnet_ids[count.index]
  connectivity_type = "private"

  tags = merge(local.tags_final, {
    Name = "private-nat-${count.index}"
  })
}
