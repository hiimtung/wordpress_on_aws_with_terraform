output "db_name" {
  value       = local.db_name
  description = "Database name"
}
output "db_hostname" {
  value       = local.db_enpoint
  description = "Database hostname"
}
output "db_username" {
  value       = local.db_username
  description = "Database master user"
}
output "db_password" {
  value       = jsondecode(aws_secretsmanager_secret_version.rds_master_credentials_version.secret_string)["password"]
  description = "Database master password"
}
