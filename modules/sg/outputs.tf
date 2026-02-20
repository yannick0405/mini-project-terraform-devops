output "security_group_id" {
  description = "ID of the Jenkins security group"
  value       = aws_security_group.this.id
}
