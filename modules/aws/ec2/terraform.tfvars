# =============================================================================
# terraform.tfvars — AWS EC2 Module
# =============================================================================

name               = "dev-web"
ami_id             = "ami-0c55b159cbfafe1f0"
instance_type      = "t3.small"
instance_count     = 1
subnet_id          = "subnet-0abc123def456"
security_group_ids = ["sg-0abc123def456"]

root_volume_size      = 20
root_volume_type      = "gp3"
root_volume_encrypted = true

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
