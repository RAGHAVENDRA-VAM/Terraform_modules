variable "name" {
  description = "Name prefix for EC2 instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
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

variable "root_volume_encrypted" {
  description = "Encrypt the root EBS volume"
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices"
  type        = list(map(string))
  default     = []
}

variable "create_eip" {
  description = "Create and attach an Elastic IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
