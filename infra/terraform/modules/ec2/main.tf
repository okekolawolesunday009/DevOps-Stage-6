resource "aws_instance" "my_ec2" {
  ami                    = var.ami# Ubuntu 20.04 AMI (update for your region)
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.local_key.key_name             # Your pem key name (without .pem)
  subnet_id              = var.epicbook_pubsub_id
  vpc_security_group_ids = var.pub_sg_id
  associate_public_ip_address = true
  tags                   = var.tags
}

locals {
  # If `ec2_key_content` is provided (e.g. via CI secret), use it; otherwise read file path from `ec2_key`.
  public_key = length(trim(var.ec2_key_content)) > 0 ? var.ec2_key_content : file(pathexpand(var.ec2_key))
}

resource "aws_key_pair" "local_key" {
  key_name   = "local-key"
  public_key = local.public_key
}


