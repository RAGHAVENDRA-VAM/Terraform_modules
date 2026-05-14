# =============================================================================
# terraform.tfvars — AWS ElastiCache Module
# =============================================================================

cluster_id     = "dev-redis"
engine         = "redis"
engine_version = "7.0"
node_type      = "cache.t3.micro"
num_cache_nodes = 1
port           = 6379

subnet_ids         = ["subnet-0abc111", "subnet-0abc222"]
security_group_ids = ["sg-0abc123def456"]

at_rest_encryption_enabled = true
transit_encryption_enabled = true
snapshot_retention_limit   = 1
snapshot_window            = "03:00-04:00"
maintenance_window         = "sun:05:00-sun:06:00"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
