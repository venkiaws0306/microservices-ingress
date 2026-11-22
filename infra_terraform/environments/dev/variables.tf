# ==========================================
# AWS General Configuration
# ==========================================

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "project_name" {
  type    = string
  default = "microservices-ingress"
}


# ==========================================
# VPC Configuration
# ==========================================

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}


# ==========================================
# Security Configuration
# ==========================================

variable "admin_cidr_blocks" {
  description = "Your trusted public IP CIDR(s), e.g. 198.51.100.20/32. Used for SSH and admin UIs."
  type        = list(string)
}

variable "eks_public_access_cidrs" {
  type = list(string)
}


# ==========================================
# Jenkins Configuration
# ==========================================

variable "jenkins_instance_type" {
  type    = string
  default = "t3.large"
}


# ==========================================
# Monitoring Configuration
# ==========================================

variable "monitoring_instance_type" {
  type    = string
  default = "t3.medium"
}


# ==========================================
# EKS Configuration
# ==========================================

variable "eks_cluster_version" {
  type    = string
  default = "1.31"
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "eks_desired_size" {
  type    = number
  default = 2
}

variable "eks_min_size" {
  type    = number
  default = 2
}

variable "eks_max_size" {
  type    = number
  default = 4
}


# ==========================================
# EC2 SSH Key Configuration
# ==========================================

variable "key_name" {
  type    = string
  default = null
}


# ==========================================
# NAT Gateway Configuration
# ==========================================

variable "enable_nat_gateway" {
  type    = bool
  default = true
}


# ==========================================
# Optional Application Load Balancer
# ==========================================

variable "enable_optional_alb" {
  type    = bool
  default = false
}


# ==========================================
# Optional RDS Configuration
# ==========================================

variable "enable_optional_rds" {
  type    = bool
  default = false
}

variable "rds_db_name" {
  type    = string
  default = "appdb"
}

variable "rds_username" {
  type    = string
  default = "appadmin"
}

variable "rds_password" {
  type      = string
  sensitive = true
  default   = null
}