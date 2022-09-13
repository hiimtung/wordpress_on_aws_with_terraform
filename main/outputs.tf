output "lb_dns_name" {
  value = module.autoscaling.alb_dns
}
output "cloudfront_domain_name" {
  value = try(module.cloudfront.cloudfront_domain_name, "")
}
output "origin_s3_bucket" {
  value = try(module.s3_static.s3_bucket_domain_name, "")
}
output "s3_log_bucket" {
  value = try(module.s3_log_bucket.s3_bucket_domain_name, "")
}
output "acm_certificate_domain" {
  value = try(module.cloudfront.acm_certificate_domain, "")
}
output "elasticache_endpoint" {
  value = module.elasticache.cluster_endpoint
}