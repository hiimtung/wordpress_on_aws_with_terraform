resource "aws_efs_file_system" "wp" {
  encrypted = true
}
resource "aws_efs_mount_target" "wp" {
  count           = length(var.efs_subnets_id)
  file_system_id  = aws_efs_file_system.wp.id
  subnet_id       = element(var.efs_subnets_id, count.index)
  security_groups = [var.efs_sg]
}
