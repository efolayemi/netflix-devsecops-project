# Create the outputs file
# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS node group"
  value       = aws_security_group.eks_nodes.id
}

# DevSecOps Tools Outputs
output "jenkins_elastic_ip" {
  description = "Jenkins Elastic IP"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins private IP"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "sonarqube_elastic_ip" {
  description = "SonarQube Elastic IP"
  value       = aws_eip.sonarqube.public_ip
}

output "sonarqube_private_ip" {
  description = "SonarQube private IP"
  value       = aws_instance.sonarqube.private_ip
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_eip.sonarqube.public_ip}:9000"
}

output "monitoring_elastic_ip" {
  description = "Monitoring Elastic IP"
  value       = aws_eip.monitoring.public_ip
}

output "monitoring_private_ip" {
  description = "Monitoring private IP"
  value       = aws_instance.monitoring.private_ip
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_eip.monitoring.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_eip.monitoring.public_ip}:3000"
}

# Keypair Information
output "keypair_name" {
  description = "Name of the keypair used for instances"
  value       = local.keypair_name
}

output "keypair_source" {
  description = "Whether keypair was created or existing was used"
  value       = var.create_new_keypair ? "created" : "existing"
}

# Connection Commands
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "ssh_jenkins_command" {
  description = "SSH command for Jenkins instance"
  value       = "ssh -i \"C:\\Users\\User\\Downloads\\CLOUDBOOSTA\\WEEK2\\cba_keypair.pem\" ec2-user@${aws_eip.jenkins.public_ip}"
}

output "ssh_sonarqube_command" {
  description = "SSH command for SonarQube instance"
  value       = "ssh -i \"C:\\Users\\User\\Downloads\\CLOUDBOOSTA\\WEEK2\\cba_keypair.pem\" ec2-user@${aws_eip.sonarqube.public_ip}"
}

output "ssh_monitoring_command" {
  description = "SSH command for Monitoring instance"
  value       = "ssh -i \"C:\\Users\\User\\Downloads\\CLOUDBOOSTA\\WEEK2\\cba_keypair.pem\" ec2-user@${aws_eip.monitoring.public_ip}"
}

# Tool IP Summary
output "devops_tools_summary" {
  description = "Summary of all DevSecOps tools and their IPs"
  value = {
    jenkins = {
      public_ip  = aws_eip.jenkins.public_ip
      private_ip = aws_instance.jenkins.private_ip
      url        = "http://${aws_eip.jenkins.public_ip}:8080"
    }
    sonarqube = {
      public_ip  = aws_eip.sonarqube.public_ip
      private_ip = aws_instance.sonarqube.private_ip
      url        = "http://${aws_eip.sonarqube.public_ip}:9000"
    }
    monitoring = {
      public_ip  = aws_eip.monitoring.public_ip
      private_ip = aws_instance.monitoring.private_ip
      prometheus = "http://${aws_eip.monitoring.public_ip}:9090"
      grafana    = "http://${aws_eip.monitoring.public_ip}:3000"
    }
  }
}