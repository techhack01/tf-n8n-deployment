# n8n AWS Deployment with Terraform

This repository contains Terraform configuration to deploy a self-hosted n8n instance on AWS using EC2 and RDS PostgreSQL for ultra-low cost deployment.

## Architecture

- **EC2 t3.micro**: Runs n8n in Docker containers (free tier eligible)
- **RDS PostgreSQL**: Managed database for n8n data persistence
- **VPC**: Isolated network with public/private subnets
- **Elastic IP**: Static IP address for consistent access
- **Security Groups**: Proper firewall rules for SSH and n8n access

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **SSH Key Pair** at `~/.ssh/id_rsa.pub` (generate with `ssh-keygen -t rsa -b 2048`)

## Quick Start

1. **Clone and navigate to the repository**:
   ```bash
   git clone <repository-url>
   cd tf-n8n-deployment
   ```

2. **Generate SSH key** (if you don't have one):
   ```bash
   ssh-keygen -t rsa -b 2048
   ```

3. **Create your configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

4. **Edit `terraform.tfvars`** with your values:
   ```hcl
   aws_region = "us-east-1"
   deployment_type = "ec2"
   db_password = "your-secure-password"
   n8n_encryption_key = "your-32-character-key-here"
   ```

5. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

6. **Access n8n**: Use the EC2 public IP from terraform output on port 5678

## Configuration Options

### Required Variables

- `db_password`: Secure password for PostgreSQL database
- `n8n_encryption_key`: 32-character string for n8n data encryption

### Optional Variables

- `n8n_domain`: Custom domain name (requires certificate_arn)
- `certificate_arn`: ACM certificate ARN for HTTPS
- `cpu`: ECS task CPU units (default: 512)
- `memory`: ECS task memory in MB (default: 1024)

## Custom Domain Setup

1. **Create ACM certificate** in AWS Console or CLI
2. **Set variables** in terraform.tfvars:
   ```hcl
   n8n_domain = "n8n.yourdomain.com"
   certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
   ```
3. **Create DNS record**: Point your domain to the ALB DNS name (from terraform output)

## Security Features

- Private subnets for ECS tasks and RDS
- Security groups with minimal required access
- Encrypted RDS storage
- HTTPS-only access with HTTP redirect
- IAM roles with least privilege

## Monitoring

- CloudWatch logs for ECS tasks
- ECS Container Insights enabled
- RDS monitoring and backups configured

## Scaling

To scale the deployment:
- Increase `desired_count` in the ECS service
- Upgrade RDS instance class for better database performance
- Adjust CPU/memory for ECS tasks

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Cost Optimization

This deployment is optimized for ultra-low AWS costs:

**Estimated Monthly Cost: $15-27**
- EC2 t3.micro: $0-8/month (free tier eligible for first year)
- RDS db.t3.micro: ~$12-15/month (free tier eligible for first year)
- Elastic IP: ~$3.6/month
- No ALB or NAT Gateway costs

### Cost-Saving Features

- **Single AZ deployment**: Reduces networking costs
- **No NAT Gateway**: Saves ~$45/month
- **No Load Balancer**: Saves ~$16/month
- **Free tier eligible**: Both EC2 and RDS can be free for first year
- **Direct HTTP access**: No SSL certificate costs

## Access and Management

### SSH Access
```bash
# Get the public IP
terraform output ec2_public_ip

# SSH to the instance
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>
```

### n8n Access
- **URL**: `http://<public-ip>:5678`
- **First Setup**: Create admin account on first visit

### Managing n8n Service
```bash
# Check status
sudo docker-compose -f /opt/n8n/docker-compose.yml ps

# View logs
sudo docker-compose -f /opt/n8n/docker-compose.yml logs -f

# Restart service
sudo docker-compose -f /opt/n8n/docker-compose.yml restart
```

## Troubleshooting

1. **Check ECS service status** in AWS Console
2. **View logs** in CloudWatch Logs group `/ecs/n8n-deployment`
3. **Verify security groups** allow proper traffic flow
4. **Check RDS connectivity** from ECS tasks
