output "instance_id" {
  value = aws_instance.this.id
}

output "instance_public_ip" {
  value = aws_instance.this.public_ip
}
output "instance_public_dns" {
  description = "DNS public de l'instance EC2"
  value       = aws_instance.this.public_dns # this est le nom de ta ressource aws_instance
}