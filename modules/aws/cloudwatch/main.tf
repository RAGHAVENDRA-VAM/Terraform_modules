resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.key
  retention_in_days = lookup(each.value, "retention_in_days", 30)
  kms_key_id        = lookup(each.value, "kms_key_id", null)
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name          = each.key
  alarm_description   = lookup(each.value, "description", "")
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = lookup(each.value, "statistic", "Average")
  threshold           = each.value.threshold
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")

  alarm_actions             = lookup(each.value, "alarm_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])

  dimensions = lookup(each.value, "dimensions", {})

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "this" {
  for_each       = var.dashboards
  dashboard_name = each.key
  dashboard_body = each.value
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.event_rules

  name                = each.key
  description         = lookup(each.value, "description", "")
  schedule_expression = lookup(each.value, "schedule_expression", null)
  event_pattern       = lookup(each.value, "event_pattern", null)
  state               = lookup(each.value, "state", "ENABLED")
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = var.event_rules

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = each.key
  arn       = each.value.target_arn
  role_arn  = lookup(each.value, "role_arn", null)
}
