resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.sg_id]
  key_name                = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}
