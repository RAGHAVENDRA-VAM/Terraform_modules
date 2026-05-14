# =============================================================================
# terraform.tfvars — AWS EKS Module
# =============================================================================

cluster_name       = "dev-eks"
kubernetes_version = "1.29"

subnet_ids = ["subnet-0abc111", "subnet-0abc222", "subnet-0abc333"]

endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]

node_groups = {
  general = {
    instance_types = ["t3.medium"]
    desired_size   = 2
    min_size       = 1
    max_size       = 4
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
  }
}

cluster_addons = {
  coredns    = {}
  kube-proxy = {}
  vpc-cni    = {}
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
