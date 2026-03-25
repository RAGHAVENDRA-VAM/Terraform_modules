resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  role       = aws_iam_role.cluster.name
  policy_arn = each.value
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }

  tags       = merge({ Name = var.cluster_name }, var.tags)
  depends_on = [aws_iam_role_policy_attachment.cluster_policies]
}

resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-role"
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

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.node_group.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = lookup(each.value, "subnet_ids", var.subnet_ids)

  instance_types = lookup(each.value, "instance_types", ["t3.medium"])
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  disk_size      = lookup(each.value, "disk_size", 20)

  scaling_config {
    desired_size = lookup(each.value, "desired_size", 2)
    min_size     = lookup(each.value, "min_size", 1)
    max_size     = lookup(each.value, "max_size", 4)
  }

  update_config {
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }

  labels = lookup(each.value, "labels", {})

  tags       = merge({ Name = "${var.cluster_name}-${each.key}" }, var.tags)
  depends_on = [aws_iam_role_policy_attachment.node_policies]
}

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = each.key
  addon_version            = lookup(each.value, "version", null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
