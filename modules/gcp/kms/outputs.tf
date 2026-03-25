output "key_ring_id" {
  description = "KMS key ring ID"
  value       = google_kms_key_ring.this.id
}

output "crypto_key_ids" {
  description = "Map of crypto key IDs"
  value       = { for k, v in google_kms_crypto_key.this : k => v.id }
}
