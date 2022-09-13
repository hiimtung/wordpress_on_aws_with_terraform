resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.origin_access_identity
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    # domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    # origin_id   = aws_s3_bucket.this.id
    domain_name = var.s3_origin_domain_name
    origin_id   = var.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }
  # Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards. Default: false.
  #retain_on_delete    = true
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cf_distribution_comment
  default_root_object = "index.html"
  aliases = var.use_acm ? [var.aliases] : []

  dynamic "logging_config" {
    for_each = length(keys(var.logging_config)) == 0 ? [] : [var.logging_config]

    content {
      include_cookies = lookup(logging_config.value, "include_cookies", null)
      bucket          = logging_config.value["bucket"]
      prefix          = lookup(logging_config.value, "prefix", null)

    }    
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    # target_origin_id = aws_s3_bucket.this.id
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    smooth_streaming = true
  }
  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = var.use_acm ? false : true
    acm_certificate_arn      = var.use_acm ? aws_acm_certificate_validation.this[0].certificate_arn : null
    ssl_support_method       = var.use_acm ? var.ssl_support_method : null
    minimum_protocol_version = var.use_acm ? var.minimum_protocol_version : null
  }
}
