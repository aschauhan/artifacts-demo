output "nacl_ids" {
  value = { for i, v in aws_network_acl.this : i => v.id }
}
