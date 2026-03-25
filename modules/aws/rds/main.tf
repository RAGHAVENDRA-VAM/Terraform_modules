resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge({ Name = "${var.identifier}-subnet-group" }, var.tags)
}

resource "aws_db_instance" "this" {
  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  parameter_group_name   = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.this[0].name

  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  performance_insights_enabled = var.performance_insights_enabled

  tags = merge({ Name = var.identifier }, var.tags)
}

resource "aws_db_parameter_group" "this" {
  count  = var.parameter_group_name == null ? 1 : 0
  name   = "${var.identifier}-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}
