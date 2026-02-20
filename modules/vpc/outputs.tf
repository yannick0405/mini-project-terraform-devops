output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}
