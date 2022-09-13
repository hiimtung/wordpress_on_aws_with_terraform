locals {
  project        = var.project
  environment    = var.environment
  resource_group = "${var.project}-${var.environment}-rsg"
  general_prefix = "${var.project}-${var.environment}"
}

locals {
  default_tags = {
    Environment   = local.environment
    Project       = local.project
    ResourceGroup = local.resource_group
  }
}
locals {
  instance_profile = aws_iam_instance_profile.this.name
  s3_allow_actions = [
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject"
  ]
}