variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devops-stage-6"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "AWS key pair name for EC2 access"
  type        = string
  default     = "devops-keypair"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "www.prod.chickenkiller.com"
}

variable "notification_email" {
  description = "Email for drift detection notifications"
  type        = string
  default     = "okekolawolsunday@gmail.com"
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/okekolawolesunday009/DevOps-Stage-6.git"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the server"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Replace with your IP for security
}