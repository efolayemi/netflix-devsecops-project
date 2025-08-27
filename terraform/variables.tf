# terraform/variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2" # London region
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "netflix-clone"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "netflix-clone-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# EKS Node Group Configuration
variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium" # Optimized for performance
}

variable "desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

# DevSecOps Tools Configuration
variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.large"
}

variable "sonarqube_instance_type" {
  description = "EC2 instance type for SonarQube"
  type        = string
  default     = "t3.large"
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for monitoring tools"
  type        = string
  default     = "t3.medium"
}

# SSH Key Configuration
variable "key_name" {
  description = "Name of AWS key pair to use for instances"
  type        = string
  default     = "cba_keypair"
}

variable "create_new_keypair" {
  description = "Whether to create a new keypair or use existing"
  type        = bool
  default     = false
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key (only used if creating new keypair)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}