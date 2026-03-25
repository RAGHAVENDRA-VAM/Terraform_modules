# AWS Elastic Beanstalk Module

Creates an Elastic Beanstalk Application + Environment with auto-scaling, load balancing, VPC integration, managed updates, and CloudWatch logging. Equivalent to Azure App Service.

## Usage

### Node.js Web App
```hcl
module "webapp" {
  source = "../../modules/aws/elastic_beanstalk"

  app_name         = "my-node-app"
  environment_name = "prod"
  solution_stack_name = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"

  vpc_id              = module.vpc.vpc_id
  instance_subnet_ids = module.vpc.private_subnet_ids
  elb_subnet_ids      = module.vpc.public_subnet_ids
  security_group_ids  = [module.sg.sg_id]

  instance_type  = "t3.small"
  min_instances  = 2
  max_instances  = 6

  deployment_policy = "Rolling"
  health_check_path = "/health"

  ssl_certificate_arn = var.acm_cert_arn

  env_vars = {
    NODE_ENV    = "production"
    DB_HOST     = module.rds.db_address
    REDIS_HOST  = module.elasticache.redis_primary_endpoint
  }

  tags = { Environment = "production" }
}
```

### Python / Django App
```hcl
module "webapp" {
  source = "../../modules/aws/elastic_beanstalk"

  app_name            = "my-django-app"
  environment_name    = "prod"
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.0 running Python 3.11"

  vpc_id              = module.vpc.vpc_id
  instance_subnet_ids = module.vpc.private_subnet_ids
  elb_subnet_ids      = module.vpc.public_subnet_ids

  env_vars = {
    DJANGO_SETTINGS_MODULE = "myapp.settings.production"
    SECRET_KEY             = var.django_secret_key
  }

  tags = { Environment = "production" }
}
```

## Common Solution Stack Names
| Runtime | Stack Name |
|---------|-----------|
| Node.js 20 | `64bit Amazon Linux 2023 v6.1.0 running Node.js 20` |
| Python 3.11 | `64bit Amazon Linux 2023 v4.1.0 running Python 3.11` |
| Java 21 | `64bit Amazon Linux 2023 v4.1.0 running Corretto 21` |
| .NET 8 | `64bit Amazon Linux 2023 v3.1.0 running .NET 8` |
| PHP 8.2 | `64bit Amazon Linux 2023 v4.1.0 running PHP 8.2` |
| Ruby 3.2 | `64bit Amazon Linux 2023 v4.1.0 running Ruby 3.2` |
| Docker | `64bit Amazon Linux 2023 v4.3.0 running Docker` |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| app_name | Application name | string | - | yes |
| environment_name | Environment suffix | string | prod | no |
| solution_stack_name | Platform stack | string | Node.js 20 | no |
| vpc_id | VPC ID | string | null | no |
| instance_subnet_ids | Instance subnets | list(string) | [] | no |
| elb_subnet_ids | LB subnets | list(string) | [] | no |
| instance_type | EC2 instance type | string | t3.small | no |
| min_instances | Min instances | number | 1 | no |
| max_instances | Max instances | number | 4 | no |
| deployment_policy | Deployment strategy | string | Rolling | no |
| env_vars | Environment variables | map(string) | {} | no |
| ssl_certificate_arn | ACM cert ARN | string | null | no |

## Outputs
| Name | Description |
|------|-------------|
| endpoint_url | Load balancer endpoint |
| cname | Environment CNAME |
| environment_id | Environment ID |
