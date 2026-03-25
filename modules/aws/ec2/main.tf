resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data
  monitoring                  = var.enable_detailed_monitoring

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge({ Name = "${var.name}-${count.index + 1}" }, var.tags)

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "this" {
  count    = var.create_eip ? var.instance_count : 0
  instance = aws_instance.this[count.index].id
  domain   = "vpc"
  tags     = merge({ Name = "${var.name}-eip-${count.index + 1}" }, var.tags)
}
