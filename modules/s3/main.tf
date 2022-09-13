data "aws_canonical_user_id" "this" {}

locals {
  grants = try(jsondecode(var.grant), var.grant)
  attach_policy = var.attach_cloudfront_oai_access_policy || var.attach_require_latest_tls_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_policy
}

resource "aws_s3_bucket" "this" {
# checkov:skip=CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
# Skip S3 bucket has cross-region replication enabled

# checkov:skip=CKV_AWS_21: Ensure all data stored in the S3 bucket have versioning enabled
# Only enable versioning for static bucket, not logging bucket

# checkov:skip=CKV_AWS_18: Ensure the S3 bucket has access logging enabled 
# Only enabled access logging for static bucket, logging bucket didn't need enable access logging 

# checkov:skip=CKV_AWS_145: Ensure that S3 buckets are encrypted with KMS by default
# S3 buckets already encrypted with SSE-S3 by default
# checkov:skip=CKV_AWS_19: Ensure all data stored in the S3 bucket is securely encrypted at rest
# All data stored in the S3 bucket already securely encrypted at rest

  bucket        = var.bucket

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "this" {
  count = ((var.acl != null && var.acl != "null") || length(local.grants) > 0) ? 1 : 0

  bucket = aws_s3_bucket.this.id
  acl = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(local.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = local.grants

        content {
          permission = grant.value.permission

          grantee {
            type          = grant.value.type
            id            = try(grant.value.id, null)
            uri           = try(grant.value.uri, null)
            email_address = try(grant.value.email, null)
          }
        }
      }
      owner {
        id           = try(var.owner["id"], data.aws_canonical_user_id.this.id)
        display_name = try(var.owner["display_name"], null)
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_enable ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_logging" "this" {
  count = length(keys(var.logging)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], null)
}
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  count = local.attach_policy ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json
}
