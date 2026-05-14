# =============================================================================
# terraform.tfvars — AWS RDS Module
# =============================================================================

identifier      = "dev-postgres"
engine          = "postgres"
engine_version  = "15.4"
instance_class  = "db.t3.medium"
db_name         = "appdb"
username        = "dbadmin"
password        = "Change_Me_Before_Apply_123!"   # use TF_VAR_password in CI/CD

subnet_ids         = ["subnet-0abc111", "subnet-0abc222"]
security_group_ids = ["sg-0abc123def456"]

allocated_storage = 20
storage_type      = "gp3"
storage_encrypted = true
multi_az          = false
deletion_protection = false
skip_final_snapshot = true

backup_retention_period = 7
backup_window           = "03:00-04:00"
maintenance_window      = "Mon:04:00-Mon:05:00"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
