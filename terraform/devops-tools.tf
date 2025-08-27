# terraform/devops-tools.tf

# Conditional key pair creation
resource "aws_key_pair" "main" {
  count = var.create_new_keypair ? 1 : 0

  key_name   = "${var.project_name}-keypair"
  public_key = file(var.ssh_public_key_path)

  tags = {
    Name = "${var.project_name}-keypair"
  }
}

# Data source for existing key pair
data "aws_key_pair" "existing" {
  count = var.create_new_keypair ? 0 : 1

  key_name = var.key_name
}

# Local value to determine which key to use
locals {
  keypair_name = var.create_new_keypair ? aws_key_pair.main[0].key_name : data.aws_key_pair.existing[0].key_name
}

# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.jenkins_instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.devops_tools.id]
  key_name               = local.keypair_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = 20
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = false
  }

  user_data = base64encode(templatefile("${path.module}/scripts/jenkins-setup.sh", {
    region       = var.aws_region
    cluster_name = var.cluster_name
  }))

  tags = {
    Name = "${var.project_name}-jenkins"
    Type = "DevSecOps-Tool"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Associate Elastic IP with Jenkins
resource "aws_eip_association" "jenkins" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins.id
}

# SonarQube Instance
resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.sonarqube_instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.devops_tools.id]
  key_name               = local.keypair_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 20
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = false
  }

  user_data = base64encode(templatefile("${path.module}/scripts/sonarqube-setup.sh", {
    region = var.aws_region
  }))

  tags = {
    Name = "${var.project_name}-sonarqube"
    Type = "DevSecOps-Tool"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Associate Elastic IP with SonarQube
resource "aws_eip_association" "sonarqube" {
  instance_id   = aws_instance.sonarqube.id
  allocation_id = aws_eip.sonarqube.id
}

# Monitoring Instance (Prometheus + Grafana)
resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.monitoring_instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.devops_tools.id]
  key_name               = local.keypair_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/scripts/monitoring-setup.sh", {
    region = var.aws_region
  }))

  tags = {
    Name = "${var.project_name}-monitoring"
    Type = "DevSecOps-Tool"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Associate Elastic IP with Monitoring
resource "aws_eip_association" "monitoring" {
  instance_id   = aws_instance.monitoring.id
  allocation_id = aws_eip.monitoring.id
}