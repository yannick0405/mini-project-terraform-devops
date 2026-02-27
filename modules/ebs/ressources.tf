resource "aws_ebs_volume" "this" {
  size              = var.size
  availability_zone = var.availability_zone
}
