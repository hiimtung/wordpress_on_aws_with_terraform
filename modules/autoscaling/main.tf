#Create launch template from ami
data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = var.ami_name
  }
  owners = var.ami_owner
}
# Create keypair for Wordpress instances
resource "tls_private_key" "wp_private_key" {
  algorithm = "RSA"
}
module "wp_keypair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = var.key_name
  public_key = tls_private_key.wp_private_key.public_key_openssh
}
# Export keypair
resource "local_file" "wp_keypair" {
  content  = tls_private_key.wp_private_key.private_key_openssh
  filename = "output/keypair/${var.key_name}.pem"
}

#Create secret manager to store wp secrets in 
resource "aws_secretsmanager_secret" "wp-adminsecret" {
  name        = "WP-admin-secret"
  kms_key_id  =  var.kms_cmk_key
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "wp-mastersecret" {
  secret_id     = aws_secretsmanager_secret.wp-adminsecret.id
  secret_string = <<EOF
    {
      "username":"${var.wp_username}",
      "password":"${var.wp_password}",
      "email":"${var.wp_email}"
    }
  EOF
}
#Import Secret manager secrets
data "aws_secretsmanager_secret" "this" {
  arn = aws_secretsmanager_secret.wp-adminsecret.arn
}
#Import Secret manager secrets version
data "aws_secretsmanager_secret_version" "creds" {
  depends_on = [
    aws_secretsmanager_secret_version.wp-mastersecret
  ]
  secret_id = data.aws_secretsmanager_secret.this.arn
}
locals {
  userdata_vars = {
    EFS_HOST       = var.efs_host
    DB_NAME        = var.db_name
    DB_HOSTNAME    = var.db_hostname
    DB_USERNAME    = var.db_username
    DB_PASSWORD    = var.db_password
    LB_HOSTNAME    = module.alb.lb_dns_name
    WP_ADMIN       = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["username"]
    WP_PASSWORD    = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["password"]
    WP_ADMIN_EMAIL = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["email"]
  }
}
resource "aws_launch_template" "ec2-wordpress" {
  name          = var.lt_name
  image_id      = data.aws_ami.ami.id
  instance_type = var.lt_instance_type
  # key_name               = var.key_name
  key_name               = module.wp_keypair.key_pair_name
  vpc_security_group_ids = [var.lt_sg]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", local.userdata_vars))
  depends_on = [
    aws_secretsmanager_secret_version.wp-mastersecret
  ]
}
#Create auto scl group from template
resource "aws_autoscaling_group" "wp-autoscaling" {
	# checkov:skip=CKV_AWS_153: This ASG using lt
  name                = var.asg_name
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = module.alb.target_group_arns #Define loadbalancing target group
  launch_template {
    id      = aws_launch_template.ec2-wordpress.id
    version = aws_launch_template.ec2-wordpress.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
#Add module alb
module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~>6.0"
  name               = var.alb_name
  load_balancer_type = "application"
  vpc_id             = var.vpc.vpc_id
  subnets            = var.vpc.public_subnets
  security_groups    = [var.lb_sg]
  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}
