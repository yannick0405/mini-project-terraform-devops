output "public_route_table_id" {
  description = "ID de la table de routage publique"
  # Vérifie que dans ton vpc/ressources.tf, la ressource s'appelle bien "public"
  value       = aws_route_table.public.id 
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}