# Cost Optimization Guide

## Current Low-Cost Configuration

The default configuration is optimized for minimal AWS costs:

### Monthly Cost Breakdown (Estimated)

**ECS Fargate Deployment:**
- ECS Fargate (0.25 vCPU, 512MB): ~$5-8/month
- RDS db.t3.micro (20GB): ~$12-15/month  
- Application Load Balancer: ~$16/month
- **Total: ~$33-39/month**

**Ultra Low-Cost EC2 Alternative:**
- EC2 t3.micro (free tier): $0-8/month
- RDS db.t3.micro (20GB): ~$12-15/month
- Elastic IP: ~$3.6/month
- **Total: ~$15-27/month**

## Cost Optimizations Applied

### 1. Single AZ Deployment
- **Savings**: ~50% on networking costs
- **Trade-off**: Reduced availability (not recommended for production)

### 2. No NAT Gateway
- **Savings**: ~$45/month per NAT Gateway
- **Trade-off**: ECS tasks run in public subnets with public IPs

### 3. Minimal Resource Allocation
- **CPU**: 256 units (0.25 vCPU) instead of 512
- **Memory**: 512MB instead of 1024MB
- **Savings**: ~40% on compute costs

### 4. Free Tier Eligible Resources
- RDS db.t3.micro (750 hours/month free for first year)
- EC2 t3.micro (750 hours/month free for first year)

## Ultra Low-Cost EC2 Deployment

For absolute minimal cost, use the EC2 deployment type:

1. **Set deployment type** in `terraform.tfvars`:
   ```hcl
   deployment_type = "ec2"
   ```

2. **Generate SSH key** (if you don't have one):
   ```bash
   ssh-keygen -t rsa -b 2048
   ```

3. **Deploy**: `terraform apply`

### EC2 Deployment Features:
- Single t3.micro instance (free tier eligible)
- Docker Compose setup
- Auto-start on boot
- Direct HTTP access on port 5678

### Access EC2 Instance:
```bash
# Get instance IP from terraform output
terraform output ec2_public_ip

# SSH to instance
ssh -i ~/.ssh/id_rsa ec2-user@<instance-ip>

# Check n8n status
sudo docker-compose -f /opt/n8n/docker-compose.yml ps
```

## Additional Cost Savings

### 1. Use Spot Instances (EC2 only)
Add to EC2 configuration:
```hcl
instance_market_options {
  market_type = "spot"
  spot_options {
    max_price = "0.01"
  }
}
```

### 2. Schedule Shutdown
For development environments, schedule EC2 shutdown:
```bash
# Stop at 6 PM daily
echo "0 18 * * * /usr/bin/docker-compose -f /opt/n8n/docker-compose.yml down" | crontab -
```

### 3. Use Reserved Instances
For long-term usage, consider RDS Reserved Instances for additional savings.

## Monitoring Costs

### AWS Cost Explorer
- Monitor daily spend
- Set up billing alerts
- Track resource usage

### CloudWatch Billing Alarms
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "BillingAlarm" \
  --alarm-description "Billing alarm" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold
```

## Production Considerations

For production workloads, consider:
- Multi-AZ deployment for high availability
- NAT Gateways for better security
- Larger instance sizes for performance
- Automated backups and monitoring
- SSL/TLS certificates for security

The low-cost configuration is ideal for:
- Development environments
- Personal projects
- Learning and experimentation
- Small team workflows