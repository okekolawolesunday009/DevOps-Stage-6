#!/bin/bash

# Update system
apt-get update -y

# Install basic packages
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L "https://github.com/docker/compose/releases/download/$${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Create application directory
mkdir -p /opt/devops-app
chown ubuntu:ubuntu /opt/devops-app

# Install Python3 and Ansible dependencies
apt-get install -y python3 python3-pip
pip3 install ansible

# Create ansible user for deployment
useradd -m -s /bin/bash ansible
usermod -aG docker ansible
echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

# Log completion
echo "$(date): User data script completed" >> /var/log/user-data.log