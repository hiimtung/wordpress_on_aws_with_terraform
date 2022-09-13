# resource "aws_s3_bucket" "this" {
#   # checkov:skip=CKV2_AWS_6: temporary skip for blocking public access
# 	# checkov:skip=CKV_AWS_21: using new resource for versioning
# 	# checkov:skip=CKV_AWS_145: temporary skip KSM
# 	# checkov:skip=CKV_AWS_144: temporary skip cross region relication
#   bucket = var.s3_bucket
 
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
#   bucket = aws_s3_bucket.this.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "AES256"
#     }
#   }
# }

# # versioning
# resource "aws_s3_bucket_versioning" "this" {
#   bucket = aws_s3_bucket.this.id

#   versioning_configuration {
#     status = var.s3_versioning_config
#   }
# }

# #enable logging 
# resource "aws_s3_bucket" "this_log_bucket" {
# 	# checkov:skip=CKV_AWS_145: Skip KSM for log
# 	# checkov:skip=CKV_AWS_19: skip Encrypt at rest for log
# 	# checkov:skip=CKV2_AWS_6: Skip ACL for log
# 	# checkov:skip=CKV_AWS_144: skip cross region relication for log
# 	# checkov:skip=CKV_AWS_21: no versioning for log
#   # checkov:skip=CKV_AWS_18: skip access logging enable
#   bucket = "this-log-bucket"
# }

# resource "aws_s3_bucket_logging" "this" {
#  bucket = aws_s3_bucket.this.id
#  target_bucket = aws_s3_bucket.this_log_bucket.id
#   target_prefix = "log/"
# }




# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = var.s3_bucket_acl
# }

# resource "aws_s3_bucket_policy" "this" {
#   bucket = aws_s3_bucket.this.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }


# resource "aws_s3_bucket_public_access_block" "this" {
#   bucket = aws_s3_bucket.this.id

#   block_public_policy     = true
#   block_public_acls       = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }


# output "s3_bucket" {
#   value = {
#     name               = aws_s3_bucket.this.bucket
#     bucket_domain_name = aws_s3_bucket.this.bucket_domain_name
#     versioning         = aws_s3_bucket.this.versioning
#   }
# }
