output "queue_id" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.url
}

output "dlq_arn" {
  description = "Dead-letter queue ARN"
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}

output "dlq_url" {
  description = "Dead-letter queue URL"
  value       = try(aws_sqs_queue.dlq[0].url, null)
}
