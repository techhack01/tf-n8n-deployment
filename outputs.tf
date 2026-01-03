output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_eip.n8n.public_ip
}

output "n8n_url" {
  description = "URL to access n8n"
  value       = "http://${aws_eip.n8n.public_ip}:5678"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.n8n.public_ip}"
}

output "database_endpoint" {
  description = "RDS instance endpoint (only if using RDS)"
  value       = var.use_rds ? aws_db_instance.n8n[0].endpoint : "Using SQLite (local database)"
  sensitive   = var.use_rds
}

output "database_type" {
  description = "Database type being used"
  value       = var.use_rds ? "PostgreSQL (RDS)" : "SQLite (local)"
}

output "ssm_connect_command" {
  description = "AWS CLI command to connect via SSM Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.n8n.id}"
}

output "ssm_console_url" {
  description = "AWS Console URL to connect via SSM Session Manager"
  value       = "https://${var.aws_region}.console.aws.amazon.com/systems-manager/session-manager/${aws_instance.n8n.id}"
}
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.n8n.id
}