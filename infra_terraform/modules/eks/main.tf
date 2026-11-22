resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster.name
}
resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "worker" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  policy_arn = each.value
  role = aws_iam_role.nodes.name
}
resource "aws_eks_cluster" "this" {
  name = var.cluster_name
  version = var.cluster_version
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs = var.public_access_cidrs
  }
  access_config { 
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true 
  }
  depends_on = [aws_iam_role_policy_attachment.cluster]
  tags = var.tags
}
resource "aws_eks_node_group" "this" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-managed-ng"
  node_role_arn = aws_iam_role.nodes.arn
  subnet_ids = var.private_subnet_ids
  instance_types = var.node_instance_types
  scaling_config {
    desired_size = var.desired_size
    min_size = var.min_size
    max_size = var.max_size
  }
  update_config { max_unavailable = 1 }
  depends_on = [aws_iam_role_policy_attachment.worker]
  tags = var.tags
}
