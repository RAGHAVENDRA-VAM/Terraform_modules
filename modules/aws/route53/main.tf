resource "aws_route53_zone" "this" {
  count   = var.create_zone ? 1 : 0
  name    = var.zone_name
  comment = var.zone_comment

  dynamic "vpc" {
    for_each = var.private_zone ? [var.vpc_id] : []
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge({ Name = var.zone_name }, var.tags)
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "alias", null) == null ? lookup(each.value, "ttl", 300) : null
  records = lookup(each.value, "alias", null) == null ? each.value.records : null

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", true)
    }
  }
}

resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  fqdn              = lookup(each.value, "fqdn", null)
  ip_address        = lookup(each.value, "ip_address", null)
  port              = lookup(each.value, "port", 443)
  type              = each.value.type
  resource_path     = lookup(each.value, "resource_path", "/")
  failure_threshold = lookup(each.value, "failure_threshold", 3)
  request_interval  = lookup(each.value, "request_interval", 30)

  tags = merge({ Name = each.key }, var.tags)
}
