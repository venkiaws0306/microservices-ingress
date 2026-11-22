locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = { Project = var.project_name, Environment = var.environment, ManagedBy = "Terraform" }
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}
module "vpc" {
  source = "../../modules/vpc"
  name = local.name
  vpc_cidr = var.vpc_cidr
  azs = local.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true
  tags = local.common_tags
}
module "jenkins_sg" {
  source = "../../modules/security-group"
  name = "${local.name}-jenkins-sg"
  vpc_id = module.vpc.vpc_id
  tags = local.common_tags
  ingress_rules = [
    { description = "SSH from admin CIDRs", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = var.admin_cidr_blocks },
    { description = "Jenkins UI from admin CIDRs", from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = var.admin_cidr_blocks }
  ]
}
module "monitoring_sg" {
  source = "../../modules/security-group"
  name = "${local.name}-monitoring-sg"
  vpc_id = module.vpc.vpc_id
  tags = local.common_tags
  ingress_rules = [
    { description = "SSH from admin CIDRs", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = var.admin_cidr_blocks },
    { description = "Grafana from admin CIDRs", from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = var.admin_cidr_blocks },
    { description = "Prometheus from admin CIDRs", from_port = 9090, to_port = 9090, protocol = "tcp", cidr_blocks = var.admin_cidr_blocks },
    { description = "Node Exporter from VPC only", from_port = 9100, to_port = 9100, protocol = "tcp", cidr_blocks = [var.vpc_cidr] }
  ]
}
resource "aws_iam_role" "jenkins" {
  name = "${local.name}-jenkins-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = local.common_tags
}
resource "aws_iam_role_policy" "jenkins_eks_read" {
  name = "${local.name}-eks-describe"
  role = aws_iam_role.jenkins.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["eks:DescribeCluster"], Resource = "*" }]
  })
}
resource "aws_iam_instance_profile" "jenkins" {
  name = "${local.name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}
module "jenkins" {
  source = "../../modules/ec2"
  name = "Ingress-Server-${var.environment}"
  ami_id = data.aws_ami.ubuntu.id
  instance_type = var.jenkins_instance_type
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.jenkins_sg.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  user_data = file("${path.module}/../../scripts/jenkins-user-data.sh")
  root_volume_size = 28
  key_name = var.key_name
  tags = local.common_tags
}
module "monitoring" {
  source = "../../modules/ec2"
  name = "Monitoring-Server-${var.environment}"
  ami_id = data.aws_ami.ubuntu.id
  instance_type = var.monitoring_instance_type
  subnet_id = module.vpc.public_subnet_ids[1]
  security_group_ids = [module.monitoring_sg.security_group_id]
  user_data = file("${path.module}/../../scripts/monitoring-user-data.sh")
  root_volume_size = 28
  key_name = var.key_name
  tags = local.common_tags
}
module "eks" {
  source = "../../modules/eks"
  cluster_name = "${local.name}-cluster"
  cluster_version = var.eks_cluster_version
  private_subnet_ids = module.vpc.private_subnet_ids
  public_access_cidrs = var.eks_public_access_cidrs
  node_instance_types = var.eks_node_instance_types
  desired_size = var.eks_desired_size
  min_size = var.eks_min_size
  max_size = var.eks_max_size
  tags = local.common_tags
}
# Optional standalone ALB example. Attach target instances/services separately.
module "optional_alb" {
  count = var.enable_optional_alb ? 1 : 0
  source = "../../modules/alb"
  name = substr(replace("${local.name}-alb", "_", "-"), 0, 32)
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  allowed_cidrs = ["0.0.0.0/0"]
  tags = local.common_tags
}
# Optional private RDS example. Password is supplied through TF_VAR_rds_password or a secrets workflow.
module "optional_rds_sg" {
  count = var.enable_optional_rds ? 1 : 0
  source = "../../modules/security-group"
  name = "${local.name}-rds-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    description = "PostgreSQL from VPC"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }]
  tags = local.common_tags
}
module "optional_rds" {
  count = var.enable_optional_rds ? 1 : 0
  source = "../../modules/rds"
  identifier = "${var.project_name}-${var.environment}-db"
  db_name = var.rds_db_name
  username = var.rds_username
  password = var.rds_password
  subnet_ids = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.optional_rds_sg[0].security_group_id]
  skip_final_snapshot = false
  tags = local.common_tags
}
