resource "aws_db_subnet_group" "ADSG" {
  name = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids
  tags = var.tags
}
resource "aws_db_instance" "this" {
  identifier = var.identifier
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type = "gp3"
  storage_encrypted = true
  db_name = var.db_name
  username = var.username
  password = var.password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible = false
  multi_az = var.multi_az
  backup_retention_period = 7
  auto_minor_version_upgrade = true
  deletion_protection = true
  skip_final_snapshot = var.skip_final_snapshot
  tags = var.tags
}
