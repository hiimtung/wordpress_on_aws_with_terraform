locals {
  iam_user = values({ for k, v in var.iam_user_name_list : k => aws_iam_user.this[k].name })
}