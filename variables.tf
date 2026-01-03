variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "n8n-deployment"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "n8n_domain" {
  description = "Domain name for n8n (optional, will use ALB DNS if not provided)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (required if using custom domain)"
  type        = string
  default     = ""
}



variable "single_az_deployment" {
  description = "Deploy in single AZ to reduce costs"
  type        = bool
  default     = true
}

variable "n8n_encryption_key" {
  description = "Encryption key for n8n (32 character string)"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}