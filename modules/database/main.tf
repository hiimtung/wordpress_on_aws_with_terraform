# Data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Create subnet group for database
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids_group
  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

data "aws_kms_key" "this" {
  key_id = "alias/aws/rds" //TODO: needed handle if RDS using KMS CMK (idea: var.storage_encrypted ? "alias/aws/rds" : var.kms_alias)  
}

# Create Aurora for MySQL
resource "aws_rds_cluster" "this" {
  count                           = var.enabled_aurora != true ? 0 : 1
  cluster_identifier              = var.db_identifier
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.07.2"
  availability_zones              = data.aws_availability_zones.available.names
  database_name                   = var.db_name
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name
  # allocated_storage               = var.allocated_storage
  master_username        = var.master_username
  master_password        = var.master_password
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = data.aws_kms_key.this.arn
  copy_tags_to_snapshot  = true
}

resource "aws_backup_plan" "this" {
  name = "${var.db_identifier}-backup-plan"

  rule {
    rule_name         = "${var.db_identifier}_backup_rule"
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.schedule_role

    lifecycle {
      delete_after = var.delete_after
    }
  }
}

resource "aws_backup_vault" "this" {
	# checkov:skip=CKV_AWS_166: temporary skip CMK for vault
  name        = "aws_backup_plan_vault"
}

resource "aws_backup_selection" "backup_db" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "${var.db_identifier}_backup_selection"
  plan_id      = aws_backup_plan.this.id
  depends_on = [
    aws_rds_cluster.this
  ]
  count     = var.enabled_aurora != true ? 0 : 1
  resources = aws_rds_cluster.this[0].arn

}

resource "aws_iam_role" "this" {
  name               = "aws_backup_selection_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    },
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "Allow",
      "Principal": {
        "Service": ["monitoring.rds.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.this.name
}

resource "aws_rds_cluster_instance" "this" {
  depends_on = [
    aws_rds_cluster.this
  ]
  count                = var.enabled_aurora != true ? 0 : var.db_cluster_size
  identifier           = "${var.db_identifier}-instance-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.this[0].id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.this[0].engine
  engine_version       = aws_rds_cluster.this[0].engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
}

resource "aws_rds_cluster_parameter_group" "this" {
  count       = var.enabled_aurora != true ? 0 : 1
  name        = "${var.db_identifier}-aurora-pg"
  family      = "aurora-mysql5.7"
  description = "Aurora cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_instance" "this" {
  count                               = var.enabled_aurora != true ? 1 : 0
  allocated_storage                   = var.allocated_storage
  engine                              = "mysql"
  engine_version                      = "5.7"
  instance_class                      = var.instance_class
  identifier                          = var.db_identifier
  db_name                             = var.db_name
  username                            = var.master_username
  password                            = var.master_password
  db_subnet_group_name                = aws_db_subnet_group.this.name
  parameter_group_name                = aws_db_parameter_group.this[0].name
  vpc_security_group_ids              = var.vpc_security_group_ids
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  kms_key_id                          = data.aws_kms_key.this.arn
  copy_tags_to_snapshot               = true
  multi_az                            = true
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]
  monitoring_interval                 = 1
  monitoring_role_arn                 = aws_iam_role.this.arn
}
resource "aws_db_parameter_group" "this" {
  count       = var.enabled_aurora != true ? 1 : 0
  name        = "${var.db_identifier}-rds-pg"
  family      = "mysql5.7"
  description = "RDS instance parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
