resource "aws_iam_role" "this" {
  count              = var.create_role ? 1 : 0
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy
  path               = var.role_path
  tags               = merge({ Name = var.role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = var.create_role ? toset(var.managed_policy_arns) : toset([])
  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.inline_policies : {}
  name     = each.key
  role     = aws_iam_role.this[0].id
  policy   = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  name  = var.role_name
  role  = aws_iam_role.this[0].name
  tags  = var.tags
}

resource "aws_iam_policy" "this" {
  count       = var.create_policy ? 1 : 0
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_document
  path        = var.policy_path
  tags        = var.tags
}

resource "aws_iam_user" "this" {
  for_each = var.users
  name     = each.key
  path     = lookup(each.value, "path", "/")
  tags     = var.tags
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for item in flatten([
      for user, cfg in var.users : [
        for arn in lookup(cfg, "policy_arns", []) : {
          key        = "${user}-${arn}"
          user       = user
          policy_arn = arn
        }
      ]
    ]) : item.key => item
  }
  user       = each.value.user
  policy_arn = each.value.policy_arn
  depends_on = [aws_iam_user.this]
}

resource "aws_iam_group" "this" {
  for_each = var.groups
  name     = each.key
  path     = lookup(each.value, "path", "/")
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for item in flatten([
      for group, cfg in var.groups : [
        for arn in lookup(cfg, "policy_arns", []) : {
          key        = "${group}-${arn}"
          group      = group
          policy_arn = arn
        }
      ]
    ]) : item.key => item
  }
  group      = each.value.group
  policy_arn = each.value.policy_arn
  depends_on = [aws_iam_group.this]
}
