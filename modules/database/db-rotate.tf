resource "aws_security_group" "lambda_rotation_sg" {
  #checkov:skip=CKV_AWS_23:Already have description
  name        = "${var.db_identifier}-lambda-rotation-sg"
  description = format("Security Group for Secrets Rotation Lambda function")
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.db_identifier}-lambda-rotation-sg"
  }

}

resource "aws_lambda_function" "rds_password_rotation" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "${path.module}/resources/rds_password_rotation/lambda_function.zip"
  function_name = "${var.db_identifier}-lambda-rds-password-rotation"
  role          = aws_iam_role.lambda_rotation_role.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/resources/rds_password_rotation/lambda_function.zip")

  runtime = "python3.7"
  vpc_config {
    subnet_ids = var.subnet_ids_group
    security_group_ids = flatten([
      aws_security_group.lambda_rotation_sg.id,
      var.vpc_security_group_ids
    ])
  }
  # kms_key_arn = data.aws_kms_key.this.arn
  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.ap-southeast-1.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secret_manager_rotate_postgre_password" {
  function_name = aws_lambda_function.rds_password_rotation.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_iam_role" "lambda_rotation_role" {
  name = "${var.db_identifier}-lambda-rotation-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "read_ec2_network_interface"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DetachNetworkInterface"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    })
  }

  inline_policy {
    name = "modify_secret_manager"

    policy = jsonencode({
      "Version" = "2012-10-17"
      "Statement" = [
        {
          "Action" : [
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            "secretsmanager:PutSecretValue",
            "secretsmanager:UpdateSecretVersionStage"
          ],
          "Resource" : aws_secretsmanager_secret_version.rds_master_credentials_version.arn,
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "secretsmanager:GetRandomPassword"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    })
  }

  inline_policy {
    name = "read_access_to_kms"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [{
        "Effect" : "Allow",
        "Action" : ["kms:DescribeKey", "kms:GenerateDataKey", "kms:Encrypt", "kms:Decrypt"],
        "Resource" : "${data.aws_kms_key.this.arn}"
      }]
    })
  }

  tags = {
    "Name" = "${var.db_identifier}-lambda-rds-password-rotation"
  }
}

resource "aws_secretsmanager_secret" "rds_master_credentials" {
  name = "${var.db_identifier}-rds-master-credentials"
  recovery_window_in_days = 0
  # kms_key_id = data.aws_kms_key.this.arn
}

resource "aws_secretsmanager_secret_version" "rds_master_credentials_version" {
  depends_on = [
    aws_secretsmanager_secret.rds_master_credentials
  ]
  secret_id     = aws_secretsmanager_secret.rds_master_credentials.id
  secret_string = <<EOF
{
  "engine": "mysql",
  "username": "${var.master_username}",
  "password": "${var.master_password}",
  "host": "${local.db_enpoint}",
  "port": 3306,
  "dbname": "${var.db_name}"
}
EOF
}
resource "aws_secretsmanager_secret_rotation" "password_rotation" {
  secret_id           = aws_secretsmanager_secret.rds_master_credentials.id
  rotation_lambda_arn = aws_lambda_function.rds_password_rotation.arn

  rotation_rules {
    automatically_after_days = var.db_password_rotation_days
  }

  depends_on = [
    aws_rds_cluster.this,
    aws_rds_cluster_instance.this,
    aws_db_instance.this,
    aws_secretsmanager_secret_version.rds_master_credentials_version
  ]
}