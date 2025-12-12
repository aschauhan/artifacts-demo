output "sg_ids" {
  value = { for name, sg in aws_security_group.this : name => sg.id }
}
