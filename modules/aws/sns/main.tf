resource "aws_sns_topic" "this" {
  name                        = var.fifo_topic ? "${var.name}.fifo" : var.name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  display_name                = var.display_name
  kms_master_key_id           = var.kms_master_key_id
  delivery_policy             = var.delivery_policy
  tags                        = merge({ Name = var.name }, var.tags)
}

resource "aws_sns_topic_policy" "this" {
  count  = var.topic_policy != null ? 1 : 0
  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  topic_arn              = aws_sns_topic.this.arn
  protocol               = each.value.protocol
  endpoint               = each.value.endpoint
  raw_message_delivery   = lookup(each.value, "raw_message_delivery", false)
  filter_policy          = lookup(each.value, "filter_policy", null)
  filter_policy_scope    = lookup(each.value, "filter_policy_scope", null)
  redrive_policy         = lookup(each.value, "redrive_policy", null)
}
