terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "kms" {
  source = "../../modules/aws/kms"

  alias       = "dev-main"
  description = "Main encryption key"
  tags        = { Environment = "dev" }
}

module "vpc" {
  source = "../../modules/aws/vpc"

  name            = "dev-vpc"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = { Environment = "dev" }
}

module "sg_web" {
  source = "../../modules/aws/security_group"

  name   = "dev-web-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { ip_protocol = "tcp", from_port = "80",  to_port = "80",  cidr_ipv4 = "0.0.0.0/0" },
    { ip_protocol = "tcp", from_port = "443", to_port = "443", cidr_ipv4 = "0.0.0.0/0" }
  ]

  tags = { Environment = "dev" }
}

module "ec2_web" {
  source = "../../modules/aws/ec2"

  name               = "dev-web"
  ami_id             = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.small"
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [module.sg_web.sg_id]
  instance_count     = 2
  tags               = { Environment = "dev" }
}

module "alb" {
  source = "../../modules/aws/alb"

  name               = "dev-alb"
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.sg_web.sg_id]

  target_groups = {
    web = { port = 80, protocol = "HTTP", health_check_path = "/health" }
  }

  create_http_listener = true
  tags                 = { Environment = "dev" }
}

module "s3_app" {
  source = "../../modules/aws/s3"

  bucket_name        = "dev-app-data-${data.aws_caller_identity.current.account_id}"
  versioning_enabled = true
  kms_key_arn        = module.kms.key_arn
  tags               = { Environment = "dev" }
}

module "rds" {
  source = "../../modules/aws/rds"

  identifier         = "dev-postgres"
  db_name            = "appdb"
  username           = "dbadmin"
  password           = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.sg_web.sg_id]
  kms_key_id         = module.kms.key_arn
  tags               = { Environment = "dev" }
}

module "sqs_jobs" {
  source = "../../modules/aws/sqs"

  name       = "dev-job-queue"
  create_dlq = true
  tags       = { Environment = "dev" }
}

module "sns_alerts" {
  source = "../../modules/aws/sns"

  name = "dev-alerts"
  subscriptions = {
    email = { protocol = "email", endpoint = "alerts@example.com" }
  }
  tags = { Environment = "dev" }
}

module "cloudwatch" {
  source = "../../modules/aws/cloudwatch"

  log_groups = {
    "/app/dev/api" = { retention_in_days = 14 }
  }

  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      threshold           = 80
      alarm_actions       = [module.sns_alerts.topic_arn]
    }
  }

  tags = { Environment = "dev" }
}

module "lambda_processor" {
  source = "../../modules/aws/lambda"

  function_name = "dev-event-processor"
  handler       = "index.handler"
  runtime       = "python3.12"
  filename      = "lambda.zip"

  environment_variables = {
    QUEUE_URL = module.sqs_jobs.queue_url
    ENV       = "dev"
  }

  event_source_mappings = {
    sqs = {
      event_source_arn = module.sqs_jobs.queue_arn
      batch_size       = 10
    }
  }

  tags = { Environment = "dev" }
}

data "aws_caller_identity" "current" {}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

output "vpc_id"       { value = module.vpc.vpc_id }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "rds_endpoint" { value = module.rds.db_endpoint }
output "s3_bucket"    { value = module.s3_app.bucket_id }
