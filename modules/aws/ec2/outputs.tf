output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.this[*].public_ip
}

output "elastic_ips" {
  description = "List of Elastic IP addresses"
  value       = aws_eip.this[*].public_ip
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = aws_instance.this[*].arn
}
