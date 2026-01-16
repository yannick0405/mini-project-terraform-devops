resource "aws_eip" "this" {
  instance = var.instance_id
}
