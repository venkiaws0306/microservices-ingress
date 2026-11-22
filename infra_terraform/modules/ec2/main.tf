resource "aws_instance" "Jenkins_Server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data
  user_data_replace_on_change = true
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = merge(var.tags, { Name = var.name })
}
