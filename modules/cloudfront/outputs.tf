output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
# output "origin_s3_bucket" {
#   value = aws_s3_bucket.this.bucket
# }
# output "origin_s3_bucket_arn" {
#   value = aws_s3_bucket.this.arn  
# }
output "acm_certificate_domain" {
  value = var.use_acm ? aws_acm_certificate.this[0].domain_name : null
}
output "cloudfront_oai_arn" {
  value = aws_cloudfront_origin_access_identity.this.iam_arn
}