variable "attach_cloudfront_oai_access_policy" {
  description = "Controls if S3 bucket only accept Cloudfront access via Origin Access Identity policy attached"
  type        = bool
  default     = false
}
variable "attach_s3_access_logging_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "cloudfront_oai_arn" {
  description = "The CloudFront Origin Access Identity arn"
  type        = string
  default     = null
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Controls if S3 bucket should require the latest version of TLS"
  type        = bool
  default     = false
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "bucket" {
  description = "The name of the bucket."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "policy" {
  description = "A valid bucket policy JSON document"
  type        = string
  default     = null
}

variable "versioning_enable" {
  description = "(Optional, Default:false ) A boolean that control versioning of bucket"
  type        = bool
  default     = false  
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "grant" {
  description = "An ACL policy grant."
  type        = any
  default     = []
}

variable "owner" {
  description = "Bucket owner's display name and ID."
  type        = map(string)
  default     = {}
}