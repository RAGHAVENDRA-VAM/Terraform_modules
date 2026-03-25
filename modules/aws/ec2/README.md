# AWS EC2 Module

Creates EC2 instances with optional EBS volumes, Elastic IPs, and IMDSv2 enforced.

## Usage

```hcl
module "ec2" {
  source = "../../modules/aws/ec2"

  name               = "web-server"
  ami_id             = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.medium"
  instance_count     = 2
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [module.security_group.sg_id]
  key_name           = "my-key-pair"

  root_volume_size      = 30
  root_volume_encrypted = true

  tags = { Environment = "production" }
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix | string | - | yes |
| ami_id | AMI ID | string | - | yes |
| instance_type | Instance type | string | t3.micro | no |
| instance_count | Number of instances | number | 1 | no |
| subnet_id | Subnet ID | string | - | yes |
| security_group_ids | Security group IDs | list(string) | [] | no |

## Outputs
| Name | Description |
|------|-------------|
| instance_ids | Instance IDs |
| private_ips | Private IPs |
| public_ips | Public IPs |
