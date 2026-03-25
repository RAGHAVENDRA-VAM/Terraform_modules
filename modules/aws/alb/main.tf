resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  idle_timeout                     = var.idle_timeout
  drop_invalid_header_fields       = true

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = each.key
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = lookup(each.value, "target_type", "instance")

  health_check {
    enabled             = true
    path                = lookup(each.value, "health_check_path", "/")
    port                = lookup(each.value, "health_check_port", "traffic-port")
    protocol            = lookup(each.value, "health_check_protocol", each.value.protocol)
    healthy_threshold   = lookup(each.value, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 3)
    interval            = lookup(each.value, "health_check_interval", 30)
    timeout             = lookup(each.value, "health_check_timeout", 5)
    matcher             = lookup(each.value, "health_check_matcher", "200")
  }

  tags = merge({ Name = each.key }, var.tags)
}

resource "aws_lb_listener" "http" {
  count             = var.create_http_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.http_redirect_to_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.http_redirect_to_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = !var.http_redirect_to_https && length(var.target_groups) > 0 ? [1] : []
      content {
        dynamic "target_group" {
          for_each = var.target_groups
          content {
            arn = aws_lb_target_group.this[target_group.key].arn
          }
        }
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.create_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.default_target_group].arn
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = var.create_https_listener ? aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group].arn
  }

  dynamic "condition" {
    for_each = lookup(each.value, "host_headers", [])
    content {
      host_header { values = [condition.value] }
    }
  }

  dynamic "condition" {
    for_each = lookup(each.value, "path_patterns", [])
    content {
      path_pattern { values = [condition.value] }
    }
  }
}
