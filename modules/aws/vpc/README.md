# AWS VPC Module

Creates a VPC with public/private subnets, Internet Gateway, NAT Gateway, and route tables.

## Usage

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  name            = "my-vpc"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = { Environment = "production" }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix | string | - | yes |
| cidr_block | VPC CIDR | string | 10.0.0.0/16 | no |
| azs | Availability zones | list(string) | - | yes |
| public_subnets | Public subnet CIDRs | list(string) | [] | no |
| private_subnets | Private subnet CIDRs | list(string) | [] | no |
| enable_nat_gateway | Enable NAT GW | bool | false | no |
| single_nat_gateway | Single NAT GW | bool | true | no |

## Outputs
| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| nat_gateway_ids | NAT Gateway IDs |
