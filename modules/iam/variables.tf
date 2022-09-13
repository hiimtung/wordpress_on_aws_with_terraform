variable "iam_user_name_list" {
  description = "hommies info"
  type        = map(any)
  #sample:
#   iam_hommie_githubaccount = {
#     iam = "githubaccountname"
#     email = "acb@xyz.com"
#     link = "https://236143222623.signin.aws.amazon.com/console"
#   }
}

variable "iam_group_name" {
  type        = string
  description = "Cloud Journey Group"
}