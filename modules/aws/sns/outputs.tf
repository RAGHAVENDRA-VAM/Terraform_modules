output "topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.this.arn
}

output "topic_id" {
  description = "SNS topic ID"
  value       = aws_sns_topic.this.id
}

output "subscription_arns" {
  description = "Map of subscription ARNs"
  value       = { for k, v in aws_sns_topic_subscription.this : k => v.arn }
}
