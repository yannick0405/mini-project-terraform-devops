output "key_name" {
  value = aws_key_pair.deployer.key_name
}

output "private_key_pem" {
  value     = tls_private_key.main.private_key_pem
  sensitive = true
}