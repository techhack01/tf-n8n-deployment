# Security Group for RDS (only if using RDS)
resource "aws_security_group" "rds" {
  count = var.use_rds ? 1 : 0
  
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_n8n.id]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}