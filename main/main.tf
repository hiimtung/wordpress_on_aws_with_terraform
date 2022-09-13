resource "random_string" "bar" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "random_string" "foo" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "random_string" "this" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

### Supporting resource ####
# Create Resource Group for Tagging and Management
resource "aws_resourcegroups_group" "resource_group" {
  name = local.resource_group

  resource_query {
    query = <<-JSON
    {
        "ResourceTypeFilters" : [
            "AWS::AllSupported"
        ],
        "TagFilters": [
            {
                "Key": "ResourceGroup",
                "Values": ["${local.resource_group}"]
            },
            {
                "Key": "Environment",
                "Values": ["${local.environment}"]
            },
            {
                "Key": "Project",
                "Values": ["${local.project}"]
            }
        ]
    }
    JSON
  }
}

#Create VPC
module "networking" {
  source         = "../modules/networking"
  vpc_name       = "${local.general_prefix}-vpc"
  vpc_cidr       = var.nw_vpc_cidr
  public_subnets = var.nw_public_subnets
  sg_prefix      = local.general_prefix
  ssh_whitelist  = var.ssh_whitelist
}
#Create Database
module "database" {
  source                    = "../modules/database"
  enabled_aurora            = false
  db_identifier             = "${local.general_prefix}-db"
  db_name                   = var.db_name
  master_username           = var.db_username
  master_password           = var.db_password
  allocated_storage         = var.db_allocated_storage
  vpc_security_group_ids    = [module.networking.db_sg]
  instance_class            = var.db_instance_class
  subnet_ids_group          = module.networking.public_subnets
  vpc_id                    = module.networking.vpc.vpc_id
  db_password_rotation_days = var.db_password_rotation_days
  depends_on = [
    module.networking
  ]
}

#Create Auto Scaling Group
module "autoscaling" {
  source               = "../modules/autoscaling"
  asg_name             = "${local.general_prefix}-asg"
  ami_name             = var.lt_ami_name
  ami_owner            = var.lt_ami_owner
  desired_capacity     = var.asg_desired_capacity
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  lt_name              = "${local.general_prefix}-lt"
  lt_instance_type     = var.asg_instance_type
  vpc_zone_identifier  = module.networking.public_subnets
  vpc                  = module.networking.vpc
  lt_sg                = module.networking.ec2_sg
  alb_name             = "${local.general_prefix}-alb"
  lb_sg                = module.networking.alb_sg
  iam_instance_profile = local.instance_profile
  key_name             = var.lt_key_name
  efs_host             = module.efs.efs_host
  db_name              = module.database.db_name
  db_hostname          = module.database.db_hostname
  db_username          = module.database.db_username
  db_password          = module.database.db_password
  wp_username          = var.asg_wp_username
  wp_password          = var.asg_wp_password
  wp_email             = var.asg_wp_email
  kms_cmk_key          = module.kms.this.arn

  depends_on = [
    module.database,
    module.efs,
    module.networking,
    module.kms
  ]
}
module "efs" {
  source         = "../modules/efs"
  efs_subnets_id = module.networking.public_subnets
  efs_sg         = module.networking.efs_sg
  depends_on = [
    module.networking
  ]
}

data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

# checkov:skip=CKV_AWS_21: Ensure all data stored in the S3 bucket have versioning enabled
# Only enable versioning for static bucket, not logging bucket

# checkov:skip=CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
# Skip S3 bucket has cross-region replication enabled

# checkov:skip=CKV_AWS_18: Ensure the S3 bucket has access logging enabled 
# Only enabled access logging for static bucket, logging bucket didn't need enable access logging 

# checkov:skip=CKV_AWS_145: Ensure that S3 buckets are encrypted with KMS by default
# S3 buckets already encrypted with SSE-S3 by default

# checkov:skip=CKV_AWS_19: Ensure all data stored in the S3 bucket is securely encrypted at rest
# All data stored in the S3 bucket already securely encrypted at rest

module "s3_log_bucket" {
  source                                = "../modules/s3"
  bucket                                = "${var.s3_bucket}-logs"
  force_destroy                         = true
  attach_s3_access_logging_policy       = true
  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    }
  ]
  owner = {
    id = data.aws_canonical_user_id.current.id
  }
}
module "s3_static" {
  source                                = "../modules/s3"
  bucket                                = var.s3_bucket
  force_destroy                         = true
  acl                                   = "private"
  attach_cloudfront_oai_access_policy   = true
  cloudfront_oai_arn                    = module.cloudfront.cloudfront_oai_arn
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  logging = {
    target_bucket = module.s3_log_bucket.s3_bucket_id
    target_prefix = "s3_logs/"
  }
  versioning_enable = true
}

module "cloudfront" {
  source = "../modules/cloudfront"
  #  use_acm = true # Default will be false, set to "True" if you want to use ACM 
  #  aliases = "cdn.cloud.forhandyman.com"
  #  route53_zone = "cloud.forhandyman.com" # Only use this option when `use_acm = true`
  logging_config = {
    # bucket = var.s3_bucket
    bucket = module.s3_log_bucket.s3_bucket_domain_name
    prefix = "cloudfront_logs/"
  }
  price_class           = "PriceClass_200"
  s3_origin_domain_name = module.s3_static.s3_bucket_regional_domain_name
  s3_origin_id          = module.s3_static.s3_bucket_id

}
module "elasticache" {
  source               = "../modules/elasticache"
  project              = local.project
  subnet_ids           = module.networking.public_subnets
  engine               = var.cache_engine
  engine_version       = var.cache_engine_version
  security_group_ids   = [module.networking.cache_sg]
  node_type            = var.cache_node_type
  num_cache_nodes      = var.cache_num_cache_nodes
  parameter_group_name = var.cache_parameter_group_name
  port                 = var.cache_port
}

module "kms" {
  source         = "../modules/kms"
  general_prefix = local.general_prefix
}
