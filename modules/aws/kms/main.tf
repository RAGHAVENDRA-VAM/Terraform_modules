resource "aws_kms_key" "this" {
  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = var.key_policy
  enable_key_rotation      = var.enable_key_rotation
  rotation_period_in_days  = var.rotation_period_in_days
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  multi_region             = var.multi_region
  tags                     = merge({ Name = var.alias }, var.tags)
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_grant" "this" {
  for_each = var.grants

  name              = each.key
  key_id            = aws_kms_key.this.key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations
}
