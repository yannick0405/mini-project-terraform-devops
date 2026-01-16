resource "aws_ebs_volume" "this" {
  size              = var.size
  availability_zone = var.availability_zone
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = var.instance_id
}
