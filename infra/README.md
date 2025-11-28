# DevOps Stage 6 - Infrastructure & Automation

Complete Infrastructure as Code setup with Terraform + Ansible automation.

## 🏗️ Infrastructure Components

### **Terraform (infra/terraform/)**
- ✅ **Idempotent Infrastructure** - No resource recreation unless drift occurs
- ✅ **Remote State Backend** - S3 bucket with versioning and encryption  
- ✅ **Drift Detection** - Automatic detection with email alerts
- ✅ **Security Groups** - HTTP/HTTPS/SSH access configured
- ✅ **Dynamic Inventory** - Auto-generates Ansible inventory
- ✅ **Auto-provisioning** - Calls Ansible after infrastructure is ready

### **Ansible (infra/ansible/)**
- ✅ **Dependencies Role** - Docker, Docker Compose, Git, security setup
- ✅ **Deploy Role** - Application deployment with idempotent restarts
- ✅ **Health Checks** - Service verification and status reporting
- ✅ **Backup System** - Automatic deployment backups

### **CI/CD Automation**
- ✅ **Infrastructure Pipeline** - Triggers on `infra/**` changes
- ✅ **Application Pipeline** - Triggers on service code changes  
- ✅ **Drift Detection** - Email alerts + manual approval for changes
- ✅ **Smart Deployment** - Only deploys if infrastructure exists

## 🚀 Quick Start

### **Single Command Deployment:**
```bash
# Make deploy script executable
chmod +x deploy.sh

# Deploy everything
./deploy.sh

# Destroy infrastructure
./deploy.sh destroy
```

### **Prerequisites:**
```bash
# Install required tools
terraform --version  # >= 1.0
ansible --version    # >= 2.9  
aws --version       # >= 2.0

# Configure AWS credentials
aws configure
```

### **Required GitHub Secrets:**
```
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
NOTIFICATION_EMAIL=your-email@domain.com
SMTP_USERNAME=your-gmail@gmail.com
SMTP_PASSWORD=your-gmail-app-password
SSH_PRIVATE_KEY=your-aws-pem-file-content
HOST=your-server-ip (auto-populated after first run)
USERNAME=ubuntu
```

## 📋 Workflow Behaviors

### **Infrastructure Changes** (`infra/**` modified):
1. **Plan** → Detect drift → Email notification
2. **Approval** → Manual approval required if drift detected  
3. **Apply** → Deploy infrastructure → Run Ansible
4. **Notify** → Success/failure email with server details

### **Application Changes** (service code modified):
1. **Check** → Verify server exists
2. **Deploy** → Only if infrastructure exists
3. **Health Check** → Verify services are running

### **Drift Detection:**
- Runs `terraform plan` on every infrastructure change
- Emails user when drift is detected
- Pauses for manual approval
- Auto-applies if no drift detected

## 🏗️ Infrastructure Details

### **AWS Resources Created:**
- **VPC** with public subnet and internet gateway
- **EC2** t3.medium instance with Ubuntu 22.04
- **Security Group** with HTTP/HTTPS/SSH access  
- **Elastic IP** for consistent public IP
- **S3 Bucket** for Terraform state (encrypted, versioned)

### **Server Configuration:**
- **Docker & Docker Compose** - Latest versions
- **Firewall** - UFW configured for required ports
- **Application Directory** - `/opt/devops-app`  
- **Backup Directory** - `/opt/backups`
- **User Permissions** - Ubuntu user in docker group

## 🔄 Idempotent Operations

### **Terraform:**
- ✅ Re-running `terraform apply` does nothing unless changes exist
- ✅ Detects configuration drift automatically
- ✅ No resource recreation unless required
- ✅ State stored remotely in S3

### **Ansible:**
- ✅ Only restarts services if code changed
- ✅ Only installs packages if missing  
- ✅ Only clones repo if not exists
- ✅ Backups created only on actual deployments

### **Application:**
- ✅ Docker images rebuilt only if source changed
- ✅ Containers restarted only if necessary
- ✅ SSL certificates auto-renewed by Traefik
- ✅ Health checks verify service status

## 📍 Access Points

After deployment:
- **Application**: https://www.prod.chickenkiller.com
- **Traefik Dashboard**: http://[SERVER-IP]:9080  
- **SSH Access**: `ssh -i aws.pem ubuntu@[SERVER-IP]`

## 🛠️ Manual Operations

### **Local Terraform:**
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### **Manual Ansible:**
```bash  
cd infra/ansible
ansible-playbook -i inventory/hosts site.yml
```

### **Check Deployment:**
```bash
# SSH to server
ssh -i aws.pem ubuntu@[SERVER-IP]

# Check services
sudo docker ps
sudo docker-compose logs

# View deployment log  
cat /opt/devops-app/deployment.log
```

## 🚨 Troubleshooting

### **Common Issues:**
1. **AWS Credentials** - Ensure `aws configure` is set up
2. **S3 Bucket** - May need to create manually first time
3. **Key Pair** - Ensure AWS key pair exists and matches variable
4. **Domain DNS** - Update DNS to point to server IP
5. **Email Notifications** - Configure Gmail app password for SMTP

### **Logs Location:**
- **Terraform**: `infra/terraform/plan.txt`
- **Deployment**: `/opt/devops-app/deployment.log`  
- **Docker**: `sudo docker-compose logs`
- **System**: `/var/log/user-data.log`

The infrastructure is fully automated, idempotent, and production-ready! 🎉