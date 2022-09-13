data "aws_kms_key" "kms_cmk" {
  depends_on = [
    aws_kms_key.kms_cmk
  ]
  key_id = aws_kms_key.kms_cmk.arn
}

resource "aws_kms_alias" "kms_alias" {
  name          = format("alias/%s", var.general_prefix)
  target_key_id = aws_kms_key.kms_cmk.key_id
}

resource "aws_kms_key" "kms_cmk" {
  depends_on = [
    aws_iam_service_linked_role.autoscaling
  ]
  description             = "Customer Managed KMS Key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "Allow_CloudWatch_for_CMK",
        "Effect": "Allow",
        "Principal": {
            "Service":[
                "cloudwatch.amazonaws.com",
                "events.amazonaws.com"
            ]
        },
        "Action": [
            "kms:Decrypt","kms:GenerateDataKey*"
        ],
        "Resource": "*"
      },
      {
        "Sid" : "Enable IAM User Permissions for root user",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid": "Allow service-linked role use of the CMK",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": "kms:CreateGrant",
        "Resource": "*",
        "Condition": {
            "Bool": {
                "kms:GrantIsForAWSResource": "true"
            }
          }
      },
      {
        "Sid": "Allow usage by CW Logs",
        "Effect": "Allow",
        "Principal": {
            "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action": [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
        ],
        "Resource": "*",
        "Condition": {
            "ArnLike": {
                "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
            }
        }
      }
      ]
  })
  tags = {
      "Name" = format("%s-kms", var.general_prefix)
    }
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
}