output "password" {
  value = { for k, v in var.iam_user_name_list : k => aws_iam_user_login_profile.this[k].password }
}

#output "csv" {
 # value = { for k, v in var.iam_user_name_list : k => local_file.this[k].content }
#}