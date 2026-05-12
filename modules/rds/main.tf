# -----------------------------
# DB SUBNET GROUP
# -----------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# -----------------------------
# RDS INSTANCE
# -----------------------------
resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  instance_class = "db.t4g.small"

  allocated_storage = 50
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az = false

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.sg_rds_id]

  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 7

  tags = {
    Name = "${var.project_name}-rds"
  }

  depends_on = [aws_db_subnet_group.this]
}