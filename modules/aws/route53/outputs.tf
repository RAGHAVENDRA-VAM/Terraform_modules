output "zone_id" {
  description = "Hosted zone ID"
  value       = try(aws_route53_zone.this[0].zone_id, var.zone_id)
}

output "zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = try(aws_route53_zone.this[0].name_servers, [])
}

output "record_fqdns" {
  description = "Map of record FQDNs"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}
