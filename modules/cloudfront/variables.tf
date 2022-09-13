variable "origin_access_identity" {
  type        = string
  default     = "Cloudfront OAI"
  description = "Comment of Cloudfront origin access identities."
}
variable "aliases" {
  type  = string
  default = null
  description = "Extra CNAMEs (Alterate domain names), if any, for this distribution"
}
variable "cf_distribution_comment" {
  type        = string
  default     = "Cloudfront Distribution"
  description = "Cloudfront Distribution Comment"
}
variable "logging_config" {
  type = any
  default = {}
  description = "The logging configuration for this distribution. Maximum one"
}
variable "price_class" {
  type = string
  default = "PriceClass_All"
  description = "The price class for this distribution. One of PriceClass_All = Use all edge locations (best performance), PriceClass_200 = Use North America, Europe, Asia, Middle East, and Africa, PriceClass_100 = Use only North America and Europe"
}

variable "use_acm" {
  type = bool
  default = false
}
variable "ssl_support_method" {
  type = string
  default = "sni-only"  
}
variable "minimum_protocol_version" {
  type = string
  default = "TLSv1.2_2021" 
}
variable "route53_zone" {
  type = string
  default = null
}
variable "s3_origin_domain_name" {
  type = string
  default = null
}
variable "s3_origin_id" {
  type = string
  default = null
}

# S3 Variables
# variable "s3_bucket" {
#   type = string
#   description = "S3 bucket name"
# }
# variable "s3_bucket_acl" {
#   type = string
#   default = "private"  
# }
# variable "s3_versioning_config" {
#   type = string
#   default = "Disabled"
# }
