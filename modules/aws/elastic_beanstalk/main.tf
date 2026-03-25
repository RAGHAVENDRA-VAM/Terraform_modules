# IAM Role for EC2 instances
resource "aws_iam_role" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.app_name}-eb-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_policies" {
  for_each = var.create_iam_role ? toset([
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]) : toset([])
  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.app_name}-eb-ec2-profile"
  role  = aws_iam_role.ec2[0].name
  tags  = var.tags
}

# IAM Service Role for Elastic Beanstalk
resource "aws_iam_role" "service" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.app_name}-eb-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "elasticbeanstalk.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "service_policies" {
  for_each = var.create_iam_role ? toset([
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
  ]) : toset([])
  role       = aws_iam_role.service[0].name
  policy_arn = each.value
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "this" {
  name        = var.app_name
  description = var.description
  tags        = merge({ Name = var.app_name }, var.tags)

  dynamic "appversion_lifecycle" {
    for_each = var.appversion_lifecycle != null ? [var.appversion_lifecycle] : []
    content {
      service_role          = var.create_iam_role ? aws_iam_role.service[0].arn : appversion_lifecycle.value.service_role_arn
      max_count             = lookup(appversion_lifecycle.value, "max_count", 10)
      delete_source_from_s3 = lookup(appversion_lifecycle.value, "delete_source_from_s3", true)
    }
  }
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "this" {
  name                   = "${var.app_name}-${var.environment_name}"
  application            = aws_elastic_beanstalk_application.this.name
  solution_stack_name    = var.solution_stack_name
  tier                   = var.tier
  wait_for_ready_timeout = var.wait_for_ready_timeout
  tags                   = merge({ Name = "${var.app_name}-${var.environment_name}" }, var.tags)

  # ─── VPC ─────────────────────────────────────────────────────────────────
  dynamic "setting" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = var.vpc_id
    }
  }

  dynamic "setting" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(",", var.instance_subnet_ids)
    }
  }

  dynamic "setting" {
    for_each = var.vpc_id != null && length(var.elb_subnet_ids) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(",", var.elb_subnet_ids)
    }
  }

  dynamic "setting" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "AssociatePublicIpAddress"
      value     = tostring(var.associate_public_ip)
    }
  }

  # ─── Launch Configuration ─────────────────────────────────────────────────
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.instance_profile_name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  dynamic "setting" {
    for_each = var.ec2_key_name != null ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = var.ec2_key_name
    }
  }

  dynamic "setting" {
    for_each = length(var.security_group_ids) > 0 ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SecurityGroups"
      value     = join(",", var.security_group_ids)
    }
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = var.root_volume_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = tostring(var.root_volume_size)
  }

  # ─── Auto Scaling ─────────────────────────────────────────────────────────
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = tostring(var.min_instances)
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = tostring(var.max_instances)
  }

  # ─── Load Balancer ────────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = var.environment_type
  }

  dynamic "setting" {
    for_each = var.environment_type == "LoadBalanced" ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "LoadBalancerType"
      value     = var.load_balancer_type
    }
  }

  dynamic "setting" {
    for_each = var.environment_type == "LoadBalanced" ? [1] : []
    content {
      namespace = "aws:elb:loadbalancer"
      name      = "CrossZone"
      value     = "true"
    }
  }

  # ─── Health Reporting ─────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = var.health_reporting_system
  }

  dynamic "setting" {
    for_each = var.health_check_path != null ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:application"
      name      = "Application Healthcheck URL"
      value     = var.health_check_path
    }
  }

  # ─── Service Role ─────────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = var.create_iam_role ? aws_iam_role.service[0].arn : var.service_role_arn
  }

  # ─── Managed Updates ──────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = tostring(var.managed_actions_enabled)
  }

  dynamic "setting" {
    for_each = var.managed_actions_enabled ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "PreferredStartTime"
      value     = var.managed_actions_start_time
    }
  }

  dynamic "setting" {
    for_each = var.managed_actions_enabled ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name      = "UpdateLevel"
      value     = "minor"
    }
  }

  # ─── Deployment Policy ────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = var.deployment_policy
  }

  dynamic "setting" {
    for_each = var.deployment_policy == "Rolling" || var.deployment_policy == "RollingWithAdditionalBatch" ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:command"
      name      = "BatchSizeType"
      value     = var.batch_size_type
    }
  }

  dynamic "setting" {
    for_each = var.deployment_policy == "Rolling" || var.deployment_policy == "RollingWithAdditionalBatch" ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:command"
      name      = "BatchSize"
      value     = tostring(var.batch_size)
    }
  }

  # ─── Environment Variables ────────────────────────────────────────────────
  dynamic "setting" {
    for_each = var.env_vars
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  # ─── CloudWatch Logs ──────────────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = tostring(var.stream_logs)
  }

  dynamic "setting" {
    for_each = var.stream_logs ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "RetentionInDays"
      value     = tostring(var.log_retention_days)
    }
  }

  # ─── HTTPS ────────────────────────────────────────────────────────────────
  dynamic "setting" {
    for_each = var.ssl_certificate_arn != null ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = "true"
    }
  }

  dynamic "setting" {
    for_each = var.ssl_certificate_arn != null ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
    }
  }

  dynamic "setting" {
    for_each = var.ssl_certificate_arn != null ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.ssl_certificate_arn
    }
  }

  # ─── Additional Custom Settings ───────────────────────────────────────────
  dynamic "setting" {
    for_each = var.additional_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }
}

# Application Version (optional - deploy a specific version)
resource "aws_elastic_beanstalk_application_version" "this" {
  count       = var.app_version_s3_bucket != null ? 1 : 0
  name        = var.app_version_label
  application = aws_elastic_beanstalk_application.this.name
  description = "Version ${var.app_version_label}"
  bucket      = var.app_version_s3_bucket
  key         = var.app_version_s3_key
  tags        = var.tags
}
