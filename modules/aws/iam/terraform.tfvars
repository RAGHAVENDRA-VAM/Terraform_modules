# =============================================================================
# terraform.tfvars — AWS IAM Module
# =============================================================================

create_role      = true
role_name        = "dev-app-role"
role_description = "Application role for dev environment"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" }
    }
  ]
}
EOF

managed_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
]

create_instance_profile = true

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
