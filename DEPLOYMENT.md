# DevOps Stage 6 - CI/CD Pipeline

This project includes automated CI/CD deployment using GitHub Actions.

## Setup Instructions

### 1. GitHub Secrets Configuration

Add these secrets to your GitHub repository (Settings → Secrets and Variables → Actions):

```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password
HOST=your-server-ip-address
USERNAME=your-server-username
SSH_PRIVATE_KEY=your-private-ssh-key
SLACK_WEBHOOK_URL=your-slack-webhook-url (optional)
```

### 2. Server Preparation

On your production server, ensure:

```bash
# Install Docker and Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER

# Create application directory
sudo mkdir -p /opt/devops-app
sudo chown $USER:$USER /opt/devops-app

# Set up SSH key authentication
# Copy your public key to ~/.ssh/authorized_keys
```

### 3. DNS Configuration

Create an A record in your DNS provider:
- **Name**: `www.prod.chickenkiller.com`
- **Type**: A  
- **Value**: Your server's public IP address

### 4. Production Environment

Update `.env.prod` with your actual values:
- Change `DOCKER_USERNAME` to your Docker Hub username
- Generate a strong `JWT_SECRET`
- Update domain name if different

## Pipeline Stages

### 1. **Test Stage**
- ✅ Frontend build test
- ✅ Java application tests  
- ✅ Node.js API tests

### 2. **Build & Push Stage**
- ✅ Builds Docker images for all services
- ✅ Pushes to Docker Hub registry
- ✅ Tags with latest and commit SHA

### 3. **Deploy Stage**
- ✅ Copies files to production server
- ✅ Zero-downtime deployment
- ✅ Health checks
- ✅ Automatic rollback on failure

### 4. **Notify Stage**
- ✅ Slack notifications (optional)
- ✅ Deployment status reporting

## Manual Deployment

For manual deployment:

```bash
# Build and push images
docker-compose build
docker-compose push

# Deploy on server
scp docker-compose.prod.yml user@server:/opt/devops-app/
scp -r traefik user@server:/opt/devops-app/
scp .env.prod user@server:/opt/devops-app/.env

# On server
cd /opt/devops-app
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

## Accessing the Application

- **Main Site**: https://www.prod.chickenkiller.com
- **Auth API**: https://www.prod.chickenkiller.com/api/auth  
- **Todos API**: https://www.prod.chickenkiller.com/api/todos
- **Users API**: https://www.prod.chickenkiller.com/api/users
- **Traefik Dashboard**: https://www.prod.chickenkiller.com/traefik

## Monitoring

- Check deployment logs: `docker-compose logs -f`
- Monitor Traefik: Access the dashboard
- Health checks: Built into the pipeline

## Rollback

```bash
# List available backups
ls /opt/backups/

# Rollback to previous version
sudo cp -r /opt/backups/devops-app-TIMESTAMP/* /opt/devops-app/
cd /opt/devops-app
docker-compose -f docker-compose.prod.yml up -d
```