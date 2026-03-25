output "app_name" {
  description = "Elastic Beanstalk application name"
  value       = aws_elastic_beanstalk_application.this.name
}

output "environment_id" {
  description = "Elastic Beanstalk environment ID"
  value       = aws_elastic_beanstalk_environment.this.id
}

output "environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment.this.name
}

output "endpoint_url" {
  description = "Load balancer / CNAME endpoint URL"
  value       = aws_elastic_beanstalk_environment.this.endpoint_url
}

output "cname" {
  description = "CNAME of the environment"
  value       = aws_elastic_beanstalk_environment.this.cname
}

output "load_balancers" {
  description = "List of load balancer ARNs"
  value       = aws_elastic_beanstalk_environment.this.load_balancers
}

output "instances" {
  description = "List of EC2 instance IDs"
  value       = aws_elastic_beanstalk_environment.this.instances
}

output "autoscaling_groups" {
  description = "List of Auto Scaling group names"
  value       = aws_elastic_beanstalk_environment.this.autoscaling_groups
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = try(aws_iam_instance_profile.ec2[0].name, null)
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = try(aws_iam_role.ec2[0].arn, null)
}

output "service_role_arn" {
  description = "Service IAM role ARN"
  value       = try(aws_iam_role.service[0].arn, null)
}
