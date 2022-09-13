
locals {
  db_name            = var.enabled_aurora != true ? aws_db_instance.this[0].db_name : aws_rds_cluster.this[0].database_name
  db_username        = var.enabled_aurora != true ? aws_db_instance.this[0].username : aws_rds_cluster.this[0].master_username
  db_reader_endpoint = var.enabled_aurora != true ? null : aws_rds_cluster.this[0].reader_endpoint
  db_enpoint         = var.enabled_aurora != true ? aws_db_instance.this[0].endpoint : aws_rds_cluster.this[0].endpoint
}
