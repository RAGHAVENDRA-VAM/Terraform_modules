output "role_arn" {
  description = "IAM role ARN"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "role_name" {
  description = "IAM role name"
  value       = try(aws_iam_role.this[0].name, null)
}

output "instance_profile_arn" {
  description = "IAM instance profile ARN"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "instance_profile_name" {
  description = "IAM instance profile name"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "policy_arn" {
  description = "IAM policy ARN"
  value       = try(aws_iam_policy.this[0].arn, null)
}

output "user_arns" {
  description = "Map of IAM user ARNs"
  value       = { for k, v in aws_iam_user.this : k => v.arn }
}
