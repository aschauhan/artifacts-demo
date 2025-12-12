locals {
  tags_final = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_route_table" "public" {
  count  = var.public_subnet_count > 0 ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(local.tags_final, {
    Name = "${var.name_prefix}-public"
  })
}

resource "aws_route" "public_igw" {
  count = var.public_subnet_count > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public_assoc" {
  count = var.public_subnet_count

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = var.private_subnet_count
  vpc_id = var.vpc_id

  tags = merge(local.tags_final, {
    Name = "${var.name_prefix}-private-${count.index}"
  })
}

resource "aws_route" "private_nat" {
  count = var.private_subnet_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_ids[count.index]
}

resource "aws_route_table_association" "private_assoc" {
  count = var.private_subnet_count

  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "non_routable" {
  count  = var.non_routable_subnet_count
  vpc_id = var.vpc_id

  tags = merge(local.tags_final, {
    Name = "${var.name_prefix}-non-routable-${count.index}"
  })
}

resource "aws_route" "non_routable_private_nat" {
  count = var.non_routable_subnet_count

  route_table_id         = aws_route_table.non_routable[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.private_nat_gateway_ids[count.index]
}

resource "aws_route_table_association" "non_routable_assoc" {
  count = var.non_routable_subnet_count

  subnet_id      = var.non_routable_subnet_ids[count.index]
  route_table_id = aws_route_table.non_routable[count.index].id
}
