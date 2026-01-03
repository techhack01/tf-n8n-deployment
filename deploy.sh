#!/bin/bash

# n8n AWS Deployment Script
set -e

echo "🚀 n8n AWS Deployment Script"
echo "=============================="

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    
    echo "⚠️  Please edit terraform.tfvars with your configuration:"
    echo "   - Set a secure db_password"
    echo "   - Set a 32-character n8n_encryption_key"
    echo "   - Optionally configure custom domain settings"
    echo ""
    echo "Press Enter when ready to continue..."
    read
fi

# Generate encryption key if needed
if ! grep -q "n8n_encryption_key.*=" terraform.tfvars || grep -q "your-32-character-encryption-key-here" terraform.tfvars; then
    echo "🔑 Generating n8n encryption key..."
    ENCRYPTION_KEY=$(openssl rand -hex 16)
    sed -i.bak "s/your-32-character-encryption-key-here/$ENCRYPTION_KEY/" terraform.tfvars
    echo "✅ Generated encryption key: $ENCRYPTION_KEY"
fi

echo "🔧 Initializing Terraform..."
terraform init

echo "📋 Planning deployment..."
terraform plan

echo ""
echo "🚀 Ready to deploy n8n to AWS!"
echo "This will create:"
echo "  - VPC with public/private subnets"
echo "  - RDS PostgreSQL database"
echo "  - ECS Fargate cluster and service"
echo "  - Application Load Balancer"
echo "  - Security groups and IAM roles"
echo ""
read -p "Continue with deployment? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying infrastructure..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Deployment complete!"
    echo ""
    echo "📊 Getting deployment information..."
    N8N_URL=$(terraform output -raw n8n_url)
    ALB_DNS=$(terraform output -raw alb_dns_name)
    
    echo ""
    echo "🎉 n8n is now deploying!"
    echo "URL: $N8N_URL"
    echo "ALB DNS: $ALB_DNS"
    echo ""
    echo "⏳ It may take 5-10 minutes for the service to be fully available."
    echo "💡 Check the ECS service status in AWS Console for deployment progress."
else
    echo "❌ Deployment cancelled."
fi