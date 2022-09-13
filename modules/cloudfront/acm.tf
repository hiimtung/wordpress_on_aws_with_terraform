provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_acm_certificate" "this" {
  count = var.use_acm ? 1 : 0
  provider          = aws.us-east-1
  domain_name       = var.aliases
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Validation acm certificate domain
resource "aws_route53_record" "this" {
  for_each = var.use_acm ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.this[0].zone_id
    }
  } : {}
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
  depends_on = [
    aws_acm_certificate.this[0]
  ]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.use_acm ? 1 : 0
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
  depends_on = [
    aws_route53_record.this
  ]
}
resource "aws_route53_record" "certificate" {
  count = var.use_acm ? 1 : 0
  name            = var.aliases
  records         = [aws_cloudfront_distribution.this.domain_name]
  ttl             = 60
  type            = "CNAME"

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.this[0].zone_id
  depends_on = [
    aws_cloudfront_distribution.this
  ]

}