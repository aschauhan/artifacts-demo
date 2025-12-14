output "subnet_ids" {
  value       = [for s in aws_subnet.this : s.id]
  description = "List of subnet IDs."
}

output "subnet_cidrs" {
  value       = [for s in aws_subnet.this : s.cidr_block]
  description = "List of subnet CIDRs."
}