output "this" {
  value = {
    arn             = aws_kms_key.kms_cmk.arn
    key_id          = aws_kms_alias.kms_alias.target_key_arn
    target_key_arn  = aws_kms_alias.kms_alias.target_key_arn
  }
}
