# Multi-Cloud Terraform Modules

Reusable Terraform modules for AWS, Azure, and GCP following the [standard module structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure).

## Structure

```
.
├── main.tf               # Root module - wires all cloud modules together
├── variables.tf          # Root variables
├── outputs.tf            # Root outputs
├── modules/
│   ├── aws/
│   │   ├── vpc/          # VPC, subnets, IGW, NAT, route tables
│   │   ├── ec2/          # EC2 instances, EBS, EIP
│   │   ├── security_group/ # Security groups with ingress/egress rules
│   │   ├── s3/           # S3 bucket, versioning, encryption, lifecycle
│   │   ├── rds/          # RDS instance, subnet group, parameter group
│   │   ├── iam/          # Roles, policies, users, groups, instance profiles
│   │   ├── eks/          # EKS cluster, node groups, addons
│   │   ├── alb/          # ALB/NLB, target groups, listeners, rules
│   │   ├── route53/      # Hosted zones, DNS records, health checks
│   │   ├── elasticache/  # Redis/Memcached replication groups
│   │   ├── sqs/          # SQS queues, DLQ, policies
│   │   ├── sns/          # SNS topics, subscriptions, policies
│   │   ├── cloudwatch/   # Log groups, alarms, dashboards, EventBridge
│   │   ├── kms/          # KMS keys, aliases, grants
│   │   └── lambda/       # Lambda functions, IAM, event sources, URLs
│   ├── azure/
│   │   ├── vnet/         # VNet, subnets, NSG, NAT Gateway
│   │   ├── vm/           # Linux/Windows VMs, NICs, managed disks
│   │   ├── aks/          # AKS cluster, node pools
│   │   ├── sql/          # Azure SQL Server, databases, firewall rules
│   │   ├── storage/      # Storage accounts, containers, queues, shares
│   │   ├── lb/           # Azure Load Balancer, backend pools, rules
│   │   ├── nsg/          # Network Security Groups, rules, associations
│   │   ├── keyvault/     # Key Vault, secrets, keys, access policies
│   │   ├── monitor/      # Log Analytics, action groups, metric alerts
│   │   └── servicebus/   # Service Bus namespace, queues, topics, subscriptions
│   └── gcp/
│       ├── vpc/          # VPC network, subnets, Cloud NAT, firewall rules
│       ├── gce/          # Compute Engine instances, disks
│       ├── gke/          # GKE cluster, node pools, workload identity
│       ├── cloudsql/     # Cloud SQL instances, databases, users, replicas
│       ├── storage/      # GCS buckets, versioning, lifecycle, IAM
│       ├── lb/           # Global/Regional HTTP(S) Load Balancer
│       ├── iam/          # Service accounts, project IAM, custom roles
│       ├── pubsub/       # Pub/Sub topics, subscriptions, IAM
│       ├── monitoring/   # Alert policies, notification channels, uptime checks
│       └── kms/          # KMS key rings, crypto keys, IAM bindings
└── examples/
    ├── aws/              # Complete AWS example
    ├── azure/            # Complete Azure example
    └── gcp/              # Complete GCP example
```

## Quick Start

### AWS Only
```hcl
terraform init
terraform apply -var="deploy_aws=true" -var="aws_db_password=<password>"
```

### Azure Only
```hcl
terraform apply -var="deploy_aws=false" -var="deploy_azure=true"
```

### GCP Only
```hcl
terraform apply -var="deploy_aws=false" -var="deploy_gcp=true" -var="gcp_project_id=my-project"
```

### All Clouds
```hcl
terraform apply \
  -var="deploy_aws=true" \
  -var="deploy_azure=true" \
  -var="deploy_gcp=true" \
  -var="aws_db_password=<password>" \
  -var="gcp_project_id=my-project"
```

## Module Usage Examples

### AWS VPC + EC2 + RDS
```hcl
module "vpc" {
  source          = "./modules/aws/vpc"
  name            = "prod-vpc"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = true
}

module "rds" {
  source             = "./modules/aws/rds"
  identifier         = "prod-db"
  db_name            = "appdb"
  username           = "admin"
  password           = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.sg.sg_id]
}
```

### Azure VNet + AKS
```hcl
module "vnet" {
  source              = "./modules/azure/vnet"
  vnet_name           = "prod-vnet"
  location            = "East US"
  resource_group_name = "rg-prod"
  address_space       = ["10.0.0.0/16"]
  subnets = {
    aks = { address_prefixes = ["10.0.1.0/24"] }
  }
}

module "aks" {
  source              = "./modules/azure/aks"
  cluster_name        = "prod-aks"
  location            = "East US"
  resource_group_name = "rg-prod"
  default_node_pool = {
    vm_size    = "Standard_D4s_v3"
    node_count = 3
    subnet_id  = module.vnet.subnet_ids["aks"]
  }
}
```

### GCP VPC + GKE
```hcl
module "vpc" {
  source       = "./modules/gcp/vpc"
  network_name = "prod-vpc"
  project_id   = var.project_id
  region       = "us-central1"
  subnets = {
    prod-subnet = {
      ip_cidr_range    = "10.0.0.0/24"
      secondary_ranges = [
        { range_name = "pods",     ip_cidr_range = "10.100.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.101.0.0/16" }
      ]
    }
  }
}

module "gke" {
  source       = "./modules/gcp/gke"
  cluster_name = "prod-gke"
  project_id   = var.project_id
  location     = "us-central1"
  network      = module.vpc.network_self_link
  subnetwork   = module.vpc.subnet_self_links["prod-subnet"]
  pods_secondary_range_name     = "pods"
  services_secondary_range_name = "services"
}
```

## Security Best Practices Applied

- All storage encrypted at rest (KMS/CMEK)
- IMDSv2 enforced on EC2 instances
- Public access blocked on S3 buckets
- TLS 1.2+ enforced on all services
- Deletion protection enabled on databases
- Private endpoints preferred over public
- Least-privilege IAM roles
- Workload Identity for GKE pods
- System-assigned managed identities for Azure resources
