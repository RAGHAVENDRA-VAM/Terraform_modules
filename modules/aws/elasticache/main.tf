resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_parameter_group" "this" {
  count  = var.parameter_group_name == null ? 1 : 0
  name   = "${var.cluster_id}-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "aws_elasticache_replication_group" "this" {
  count = var.engine == "redis" ? 1 : 0

  replication_group_id = var.cluster_id
  description          = var.description
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_nodes
  port                 = var.port
  engine_version       = var.engine_version

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.security_group_ids
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.this[0].name

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  kms_key_id                 = var.kms_key_id

  automatic_failover_enabled = var.num_cache_nodes > 1 ? true : false
  multi_az_enabled           = var.multi_az_enabled

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge({ Name = var.cluster_id }, var.tags)
}

resource "aws_elasticache_cluster" "this" {
  count = var.engine == "memcached" ? 1 : 0

  cluster_id           = var.cluster_id
  engine               = "memcached"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = var.port
  engine_version       = var.engine_version
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = var.security_group_ids
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.this[0].name
  maintenance_window   = var.maintenance_window

  tags = merge({ Name = var.cluster_id }, var.tags)
}
