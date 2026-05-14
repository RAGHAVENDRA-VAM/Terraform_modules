# =============================================================================
# terraform.tfvars — AWS SQS Module
# =============================================================================

name       = "dev-job-queue"
fifo_queue = false

visibility_timeout_seconds = 30
message_retention_seconds  = 345600
delay_seconds              = 0
receive_wait_time_seconds  = 10

create_dlq      = true
max_receive_count = 5

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
