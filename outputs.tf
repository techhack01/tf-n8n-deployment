output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_eip.n8n.public_ip
}

output "n8n_url" {
  description = "URL to access n8n"
  value       = "http://${aws_eip.n8n.public_ip}:5678"
}

output "ssh_command" {
  description = "SSH command to connect to the instance (only if SSH key was created)"
  value       = var.create_ssh_key ? "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.n8n.public_ip}" : "SSH key not configured - use SSM Session Manager instead"
}

output "database_type" {
  description = "Database type being used"
  value       = "SQLite (local file database)"
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