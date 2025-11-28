[app_servers]
${server_ip} ansible_user=${server_user} ansible_ssh_private_key_file=${key_file}

[app_servers:vars]
domain_name=${domain_name}
github_repo=${github_repo}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'