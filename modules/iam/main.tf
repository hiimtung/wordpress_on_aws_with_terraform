resource "aws_iam_group" "this" {
  name = var.iam_group_name
}

resource "aws_iam_policy" "this" {
  name = "forceMFA"
  description = "Require MFA for IAM User"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllUsersToListAccounts",
            "Effect": "Allow",
            "Action": [
                "iam:ListAccountAliases",
                "iam:ListUsers",
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation",
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:CreateVirtualMFADevice",
                "iam:ListMFADevices",
                "iam:DeleteVirtualMFADevice",
                "iam:ListVirtualMFADevices",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:CreateLoginProfile",
                "iam:DeleteAccessKey",
                "iam:DeleteLoginProfile",
                "iam:GetLoginProfile",
                "iam:ListAccessKeys",
                "iam:UpdateAccessKey",
                "iam:UpdateLoginProfile",
                "iam:ListSigningCertificates",
                "iam:DeleteSigningCertificate",
                "iam:UpdateSigningCertificate",
                "iam:UploadSigningCertificate",
                "iam:ListSSHPublicKeys",
                "iam:GetSSHPublicKey",
                "iam:DeleteSSHPublicKey",
                "iam:UpdateSSHPublicKey",
                "iam:UploadSSHPublicKey"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA",
            "Effect": "Allow",
            "Action": [
                "iam:DeactivateMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ],
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "true"
                }
            }
        },
        {
            "Sid": "BlockMostAccessUnlessSignedInWithMFA",
            "Effect": "Deny",
            "NotAction": [
                "iam:ChangePassword",
                "iam:CreateVirtualMFADevice",
                "iam:DeleteVirtualMFADevice",
                "iam:ListVirtualMFADevices",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:ListAccountAliases",
                "iam:ListUsers",
                "iam:ListSSHPublicKeys",
                "iam:ListAccessKeys",
                "iam:ListServiceSpecificCredentials",
                "iam:ListMFADevices",
                "iam:GetAccountSummary",
                "sts:GetSessionToken"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
EOT
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "force_mfa" {
  depends_on = [
    aws_iam_policy.this
  ]
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_user" "this" {
  depends_on = [
    aws_iam_group.this
  ]
  for_each = var.iam_user_name_list
  name     = each.value.iam
  path     = "/"
  # force_destroy = true
}

resource "aws_iam_group_membership" "this" {
  depends_on = [
    aws_iam_group.this,
    local.iam_user
  ]
  name = "cloud-journey-group"

  users = values({ for k, v in var.iam_user_name_list : k => aws_iam_user.this[k].name })
  group = aws_iam_group.this.name
}

resource "aws_iam_user_login_profile" "this" {
  # depends_on = { for k in var.iam_user_name_list : k => aws_iam_user.this[k].name }
  for_each                = var.iam_user_name_list
  user                    = aws_iam_user.this[each.key].name
  password_reset_required = true
  password_length         = 12
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required
      ]
  }
}

#resource "local_file" "this" {
#  for_each = var.iam_user_name_list
# content  = "iam,password,link\n${each.value.iam},${aws_iam_user_login_profile.this[each.key].password},${each.value.link}"
# filename = "${each.key}.csv"
#}

