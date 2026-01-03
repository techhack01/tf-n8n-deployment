# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair for EC2 access (optional)
resource "aws_key_pair" "n8n" {
  count = var.create_ssh_key ? 1 : 0
  
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key_content
}

# Security Group for EC2
resource "aws_security_group" "ec2_n8n" {
  name_prefix = "${var.project_name}-ec2-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "n8n"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# EC2 Instance
resource "aws_instance" "n8n" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = var.create_ssh_key ? aws_key_pair.n8n[0].key_name : null
  vpc_security_group_ids = [aws_security_group.ec2_n8n.id]
  subnet_id              = aws_subnet.public[0].id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    encryption_key = var.n8n_encryption_key
  }))

  tags = {
    Name = "${var.project_name}-instance"
  }
}

# Elastic IP for static IP
resource "aws_eip" "n8n" {
  instance = aws_instance.n8n.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}