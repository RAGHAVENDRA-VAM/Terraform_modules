output "topic_ids" {
  description = "Map of topic IDs"
  value       = { for k, v in google_pubsub_topic.this : k => v.id }
}

output "subscription_ids" {
  description = "Map of subscription IDs"
  value       = { for k, v in google_pubsub_subscription.this : k => v.id }
}
