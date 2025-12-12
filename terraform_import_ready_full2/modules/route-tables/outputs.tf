output "public_route_table_id" {
  value       = try(aws_route_table.public[0].id, null)
  description = "Single public route table ID."
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "Private route table IDs."
}

output "non_routable_route_table_ids" {
  value       = aws_route_table.non_routable[*].id
  description = "Non-routable route table IDs."
}
