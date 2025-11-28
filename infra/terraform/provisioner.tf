# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    server_ip   = aws_eip.app_server.public_ip
    server_user = "ubuntu"
    key_file    = "aws.pem"
    domain_name = var.domain_name
    github_repo = var.github_repo
  })
  
  filename        = "${path.module}/../ansible/inventory/hosts"
  file_permission = "0644"

  depends_on = [aws_instance.app_server]
}

# Run Ansible Playbook after infrastructure is ready
resource "null_resource" "run_ansible" {
  depends_on = [
    aws_instance.app_server,
    local_file.ansible_inventory
  ]

  triggers = {
    instance_id   = aws_instance.app_server.id
    inventory_md5 = md5(local_file.ansible_inventory.content)
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 60  # Wait for instance to be fully ready
      cd ${path.module}/../ansible
      ansible-playbook -i inventory/hosts site.yml --extra-vars "target_host=app_servers"
    EOT
  }
}

# S3 Bucket for Terraform State (if it doesn't exist)
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-stage-6-terraform-state"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}