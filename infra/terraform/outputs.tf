output "server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_server.public_ip
}

output "server_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "server_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_server.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "ansible_inventory" {
  description = "Ansible inventory content"
  value = templatefile("${path.module}/inventory.tpl", {
    server_ip    = aws_eip.app_server.public_ip
    server_user  = "ubuntu"
    key_file     = "~/.ssh/${var.key_pair_name}.pem"
    domain_name  = var.domain_name
    github_repo  = var.github_repo
  })
}