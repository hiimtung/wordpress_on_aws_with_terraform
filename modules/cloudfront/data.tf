# Route 53 Domain Zone
data "aws_route53_zone" "this" {
  count = var.use_acm ? 1 : 0
  name         = var.route53_zone
  private_zone = false
}

# S3 bucket policy: Allow GetObject from Cloudfront only
# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     sid       = "CloudFront OAI"
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.this.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
#     }
#   }
# }