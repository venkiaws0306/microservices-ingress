# RDS instance identifier
variable "identifier" {
  type = string
}

# Database engine
variable "engine" {
  type    = string
  default = "postgres"
}

# PostgreSQL version
variable "engine_version" {
  type    = string
  default = "16.4"
}

# RDS instance size
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

# Database storage in GB
variable "allocated_storage" {
  type    = number
  default = 20
}

# Initial database name
variable "db_name" {
  type = string
}

# Database master username
variable "username" {
  type = string
}

# Database master password
variable "password" {
  type      = string
  sensitive = true
}

# Private subnet IDs for RDS
variable "subnet_ids" {
  type = list(string)
}

# Security groups attached to RDS
variable "vpc_security_group_ids" {
  type = list(string)
}

# Whether to skip the final snapshot during deletion
variable "skip_final_snapshot" {
  type    = bool
  default = false
}

# Enable or disable Multi-AZ
variable "multi_az" {
  type    = bool
  default = false
}

# Resource tags
variable "tags" {
  type    = map(string)
  default = {}
}