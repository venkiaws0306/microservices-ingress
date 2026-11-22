# EKS Cluster Name
variable "cluster_name" {
  type = string
}

# Kubernetes Cluster Version
variable "cluster_version" {
  type    = string
  default = "1.31"
}

# Private Subnet IDs for EKS
variable "private_subnet_ids" {
  type = list(string)
}

# Allowed CIDR blocks for public API access
variable "public_access_cidrs" {
  type = list(string)
}

# EKS Worker Node Instance Types
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

# Desired Number of Worker Nodes
variable "desired_size" {
  type    = number
  default = 2
}

# Minimum Number of Worker Nodes
variable "min_size" {
  type    = number
  default = 2
}

# Maximum Number of Worker Nodes
variable "max_size" {
  type    = number
  default = 4
}

# Resource Tags
variable "tags" {
  type    = map(string)
  default = {}
}