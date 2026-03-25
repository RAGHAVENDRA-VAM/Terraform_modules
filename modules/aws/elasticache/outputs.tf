output "redis_primary_endpoint" {
  description = "Redis primary endpoint address"
  value       = try(aws_elasticache_replication_group.this[0].primary_endpoint_address, null)
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint address"
  value       = try(aws_elasticache_replication_group.this[0].reader_endpoint_address, null)
}

output "memcached_cluster_address" {
  description = "Memcached cluster address"
  value       = try(aws_elasticache_cluster.this[0].cluster_address, null)
}

output "port" {
  description = "Cache port"
  value       = var.port
}
