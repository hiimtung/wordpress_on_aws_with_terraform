data "aws_iam_policy_document" "combined" {
  count = local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_cloudfront_oai_access_policy ? data.aws_iam_policy_document.cloudfront_oai_access_policy[0].json : "",
    var.attach_s3_access_logging_policy ? data.aws_iam_policy_document.s3_access_logging_policy[0].json : "",
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_require_latest_tls_policy ? data.aws_iam_policy_document.require_latest_tls[0].json : "",
    var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
    var.attach_policy ? var.policy : ""
  ])
}

# Cloudfront OAI Access Policy
data "aws_iam_policy_document" "cloudfront_oai_access_policy" {
  count = var.attach_cloudfront_oai_access_policy ? 1 : 0

  statement {
    sid       = "CloudFront OAI"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      #identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
      identifiers = [var.cloudfront_oai_arn]
    }
  }
}

# S3 Access logging
data "aws_iam_policy_document" "s3_access_logging_policy" {
  count = var.attach_s3_access_logging_policy ? 1 : 0

  statement {
    sid = "S3ServerAccessLogsPolicy"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# ALB/NLB

data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.attach_lb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  count = var.attach_deny_insecure_transport_policy ? 1 : 0

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "require_latest_tls" {
  count = var.attach_require_latest_tls_policy ? 1 : 0

  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}