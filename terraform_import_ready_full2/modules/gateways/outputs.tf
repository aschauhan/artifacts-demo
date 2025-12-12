output "igw_id" {
  description = "Internet Gateway ID (or null)."
  value       = length(aws_internet_gateway.igw) > 0 ? aws_internet_gateway.igw[0].id : null
}

output "nat_gateway_ids" {
  description = "List of public NAT Gateway IDs."
  value       = aws_nat_gateway.nat_gw[*].id
}

output "private_nat_gateway_ids" {
  description = "List of private NAT Gateway IDs."
  value       = aws_nat_gateway.private_nat_gw[*].id
}
