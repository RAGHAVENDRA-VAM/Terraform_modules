resource "aws_sqs_queue" "this" {
  name                        = var.fifo_queue ? "${var.name}.fifo" : var.name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  redrive_policy = var.dead_letter_queue_arn != null ? jsonencode({
    deadLetterTargetArn = var.dead_letter_queue_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0
  name  = var.fifo_queue ? "${var.name}-dlq.fifo" : "${var.name}-dlq"
  fifo_queue = var.fifo_queue
  message_retention_seconds = var.dlq_message_retention_seconds
  tags = merge({ Name = "${var.name}-dlq" }, var.tags)
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count     = var.create_dlq ? 1 : 0
  queue_url = aws_sqs_queue.dlq[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}

resource "aws_sqs_queue_policy" "this" {
  count     = var.queue_policy != null ? 1 : 0
  queue_url = aws_sqs_queue.this.id
  policy    = var.queue_policy
}
