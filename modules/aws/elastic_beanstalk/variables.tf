variable "app_name" {
  description = "Elastic Beanstalk application name"
  type        = string
}

variable "description" {
  description = "Application description"
  type        = string
  default     = "Managed by Terraform"
}

variable "environment_name" {
  description = "Environment name suffix (e.g., prod, staging)"
  type        = string
  default     = "prod"
}

# ─── IAM ─────────────────────────────────────────────────────────────────────

variable "create_iam_role" {
  description = "Create IAM roles for EC2 and service"
  type        = bool
  default     = true
}

variable "instance_profile_name" {
  description = "Existing EC2 instance profile name (when create_iam_role = false)"
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "Existing service role ARN (when create_iam_role = false)"
  type        = string
  default     = null
}

# ─── Platform ────────────────────────────────────────────────────────────────

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name"
  type        = string
  default     = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
}

variable "tier" {
  description = "Environment tier: WebServer or Worker"
  type        = string
  default     = "WebServer"
}

# ─── VPC / Network ───────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "instance_subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
  default     = []
}

variable "elb_subnet_ids" {
  description = "Subnet IDs for the load balancer"
  type        = list(string)
  default     = []
}

variable "associate_public_ip" {
  description = "Associate public IP to instances"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Additional security group IDs for instances"
  type        = list(string)
  default     = []
}

# ─── Instance ────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "EC2 key pair name for SSH"
  type        = string
  default     = null
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

# ─── Auto Scaling ────────────────────────────────────────────────────────────

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

# ─── Load Balancer ───────────────────────────────────────────────────────────

variable "environment_type" {
  description = "SingleInstance or LoadBalanced"
  type        = string
  default     = "LoadBalanced"
}

variable "load_balancer_type" {
  description = "Load balancer type: classic, application, network"
  type        = string
  default     = "application"
}

variable "ssl_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

# ─── Health ──────────────────────────────────────────────────────────────────

variable "health_reporting_system" {
  description = "Health reporting: basic or enhanced"
  type        = string
  default     = "enhanced"
}

variable "health_check_path" {
  description = "Health check URL path"
  type        = string
  default     = "/health"
}

# ─── Deployment ──────────────────────────────────────────────────────────────

variable "deployment_policy" {
  description = "Deployment policy: AllAtOnce, Rolling, RollingWithAdditionalBatch, Immutable, TrafficSplitting"
  type        = string
  default     = "Rolling"
}

variable "batch_size_type" {
  description = "Batch size type: Fixed or Percentage"
  type        = string
  default     = "Percentage"
}

variable "batch_size" {
  description = "Batch size value"
  type        = number
  default     = 30
}

variable "wait_for_ready_timeout" {
  description = "Timeout waiting for environment to be ready"
  type        = string
  default     = "20m"
}

# ─── Managed Updates ─────────────────────────────────────────────────────────

variable "managed_actions_enabled" {
  description = "Enable managed platform updates"
  type        = bool
  default     = true
}

variable "managed_actions_start_time" {
  description = "Preferred start time for managed updates (e.g., Sun:10:00)"
  type        = string
  default     = "Sun:10:00"
}

# ─── Environment Variables ───────────────────────────────────────────────────

variable "env_vars" {
  description = "Application environment variables"
  type        = map(string)
  default     = {}
}

# ─── Logging ─────────────────────────────────────────────────────────────────

variable "stream_logs" {
  description = "Stream logs to CloudWatch"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# ─── App Version ─────────────────────────────────────────────────────────────

variable "appversion_lifecycle" {
  description = "Application version lifecycle configuration"
  type        = map(any)
  default     = null
}

variable "app_version_s3_bucket" {
  description = "S3 bucket containing the application version"
  type        = string
  default     = null
}

variable "app_version_s3_key" {
  description = "S3 key of the application version zip"
  type        = string
  default     = null
}

variable "app_version_label" {
  description = "Application version label"
  type        = string
  default     = "v1.0.0"
}

# ─── Additional Settings ─────────────────────────────────────────────────────

variable "additional_settings" {
  description = "List of additional Elastic Beanstalk option settings"
  type = list(object({
    namespace = string
    name      = string
    value     = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
