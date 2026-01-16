resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.this.id
  route_table_id = var.public_rt_id
}