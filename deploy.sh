#!/bin/bash

# Single Command Deployment Script
# Usage: ./deploy.sh [destroy]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/infra/terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    command -v terraform >/dev/null 2>&1 || { error "Terraform is required but not installed."; exit 1; }
    command -v ansible >/dev/null 2>&1 || { error "Ansible is required but not installed."; exit 1; }
    command -v aws >/dev/null 2>&1 || { error "AWS CLI is required but not installed."; exit 1; }
    
    # Check AWS credentials
    aws sts get-caller-identity >/dev/null 2>&1 || { error "AWS credentials not configured."; exit 1; }
    
    success "Prerequisites check passed"
}

# Initialize Terraform
init_terraform() {
    log "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform init
    success "Terraform initialized"
}

# Run Terraform plan and check for drift
check_drift() {
    log "Running Terraform plan to detect drift..."
    cd "$TERRAFORM_DIR"
    
    terraform plan -detailed-exitcode -out=tfplan.out | tee plan.txt
    plan_exit_code=$?
    
    case $plan_exit_code in
        0)
            success "No infrastructure changes required"
            return 0
            ;;
        1)
            error "Terraform plan failed"
            exit 1
            ;;
        2)
            warn "Infrastructure drift detected!"
            echo
            cat plan.txt
            echo
            read -p "Do you want to apply these changes? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                return 2
            else
                error "Deployment cancelled by user"
                exit 1
            fi
            ;;
    esac
}

# Apply Terraform changes
apply_terraform() {
    local has_changes=$1
    log "Applying Terraform configuration..."
    cd "$TERRAFORM_DIR"
    
    if [ "$has_changes" -eq 2 ]; then
        terraform apply -auto-approve tfplan.out
    else
        terraform refresh
    fi
    
    success "Infrastructure deployment completed"
}

# Get infrastructure outputs
get_outputs() {
    log "Retrieving infrastructure outputs..."
    cd "$TERRAFORM_DIR"
    
    SERVER_IP=$(terraform output -raw server_public_ip 2>/dev/null || echo "")
    
    if [ -n "$SERVER_IP" ]; then
        success "Server deployed at IP: $SERVER_IP"
        echo "SERVER_IP=$SERVER_IP" > "$SCRIPT_DIR/.env.infra"
    else
        error "Could not retrieve server IP"
        exit 1
    fi
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    if [ -n "$SERVER_IP" ]; then
        # Wait for services to be ready
        log "Waiting for services to start..."
        sleep 30
        
        # Check HTTP endpoint
        if curl -f -s "http://$SERVER_IP:8080" >/dev/null 2>&1; then
            success "Application is responding on HTTP"
        else
            warn "Application not yet responding on HTTP (this is normal for first deployment)"
        fi
        
        # Check if HTTPS will work (domain resolution)
        if nslookup www.prod.chickenkiller.com >/dev/null 2>&1; then
            if curl -f -s "https://www.prod.chickenkiller.com" >/dev/null 2>&1; then
                success "Application is responding on HTTPS"
            else
                warn "HTTPS not yet ready (SSL certificate may be provisioning)"
            fi
        else
            warn "Domain not resolving - update DNS to point www.prod.chickenkiller.com to $SERVER_IP"
        fi
    fi
}

# Destroy infrastructure
destroy_infrastructure() {
    warn "This will destroy all infrastructure!"
    read -p "Are you absolutely sure? Type 'destroy' to confirm: " -r
    echo
    if [ "$REPLY" = "destroy" ]; then
        log "Destroying infrastructure..."
        cd "$TERRAFORM_DIR"
        terraform destroy -auto-approve
        success "Infrastructure destroyed"
        rm -f "$SCRIPT_DIR/.env.infra"
    else
        error "Destruction cancelled"
        exit 1
    fi
}

# Main deployment function
main_deploy() {
    log "Starting single-command deployment..."
    
    check_prerequisites
    init_terraform
    
    check_drift
    drift_status=$?
    
    apply_terraform $drift_status
    get_outputs
    verify_deployment
    
    success "Deployment completed successfully!"
    echo
    echo "═══════════════════════════════════════════════"
    echo "🚀 DevOps Stage 6 - Deployment Complete"
    echo "═══════════════════════════════════════════════"
    echo "Server IP: $SERVER_IP"
    echo "Application: https://www.prod.chickenkiller.com"
    echo "Traefik Dashboard: http://$SERVER_IP:9080"
    echo ""
    echo "Next steps:"
    echo "1. Update DNS: www.prod.chickenkiller.com -> $SERVER_IP"
    echo "2. Wait for SSL certificate provisioning (~2-5 minutes)"
    echo "3. Access your application at https://www.prod.chickenkiller.com"
    echo "═══════════════════════════════════════════════"
}

# Main execution
case "${1:-deploy}" in
    "destroy")
        destroy_infrastructure
        ;;
    "deploy"|"")
        main_deploy
        ;;
    *)
        echo "Usage: $0 [deploy|destroy]"
        echo "  deploy   - Deploy infrastructure and application (default)"
        echo "  destroy  - Destroy all infrastructure"
        exit 1
        ;;
esac