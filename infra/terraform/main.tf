data "aws_caller_identity" "current" {}

locals {
  environment    = terraform.workspace == "prod" ? "prod" : "dev"
  aws_account    = data.aws_caller_identity.current.account_id
  aws_user_id    = data.aws_caller_identity.current.user_id
  ec2_key   = var.ec2_key
  tags = {
    env      = local.environment
    location = var.aws_region
  }
}

provider "aws" {
  # profile = var.aws_profile
  region = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"
  # sg_id  = module.sg.sg_id
  aws_region      = var.aws_region
  pub_sg_id = [module.net.pub_sg_id]
  ami = var.ami
  ec2_key = var.ec2_key
  epicbook_pubsub_id = module.net.epicbook_pubsub_id
  tags      = local.tags
}


module "net" {
  source      = "./modules/net"
  projectname = var.projectname
  aws_region = var.aws_region
  tags        = local.tags
}



# Write an Ansible inventory file using local_file and templatefile
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = templatefile("${path.module}/templates/ansible_inventory.tmpl", {
    host_ip = module.ec2.public_ip
    user    = "ubuntu"
    ssh_key = var.ssh_private_key_path
  })
}

# Write group_vars (json) that Ansible can use
resource "local_file" "ansible_group_vars" {
  filename = "${path.module}/../ansible/group_vars/web.json"
  content  = jsonencode({
    public_ip = module.ec2.public_ip
    # instance_id = module.ec2.instance_id
    domain = var.domain
  })
}

# Null resource to run Ansible. It will run only when the instance changes or inventory file changes.
resource "null_resource" "run_ansible" {
  triggers = {
    # instance_id     = module.ec2.instance_id
    instance_pub_ip = module.ec2.public_ip
    inventory_path  = local_file.ansible_inventory.filename
    # add other triggers if needed (e.g., git commit hash)
  }

  provisioner "local-exec" {
  command = <<EOT
    echo '[INFO] Waiting for SSH connection to be ready...'
    until ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@${module.ec2.public_ip} 'echo ready'; do
      echo '[INFO] SSH not ready yet, waiting 10s...'
      sleep 10
    done
    echo '[INFO] SSH ready! Running Ansible playbook...'
    cd ${path.module}/../ansible
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini site.yml
  EOT

  interpreter = ["bash", "-c"]
}

depends_on = [
  local_file.ansible_inventory,
  local_file.ansible_group_vars,
  module.ec2
]
}



