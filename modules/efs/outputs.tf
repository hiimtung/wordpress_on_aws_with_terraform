output "efs_host" {
  value = aws_efs_file_system.wp.dns_name
}
output "efs_mounts" {
  value = aws_efs_mount_target.wp.*.dns_name
}
