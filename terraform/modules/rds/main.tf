################################################################################
# KMS Key for RDS encryption
################################################################################
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption – ${var.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-rds-kms" })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.name_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

################################################################################
# DB Subnet Group
################################################################################
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = var.db_subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

################################################################################
# Security Group
################################################################################
resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds-"
  description = "Allow MySQL access from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.ecs_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rds-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Secrets Manager – master credentials (auto-generated)
################################################################################
resource "aws_secretsmanager_secret" "db_master" {
  name                    = "${var.name_prefix}/rds/master"
  description             = "RDS master credentials"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.rds.arn

  tags = var.tags
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "db_master" {
  secret_id = aws_secretsmanager_secret.db_master.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = random_password.master.result
    engine   = "mysql"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
}

################################################################################
# RDS Instance
################################################################################
resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-mysql"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_master_username
  password = random_password.master.result

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-mysql-final"
  deletion_protection       = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-mysql" })
}
