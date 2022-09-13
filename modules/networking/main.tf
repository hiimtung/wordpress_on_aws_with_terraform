#Create VPC from terraform's modules
data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source                           = "terraform-aws-modules/vpc/aws"
  version                          = "3.14.2"
  name                             = var.vpc_name
  cidr                             = var.vpc_cidr
  azs                              = data.aws_availability_zones.available.names
  public_subnets                   = var.public_subnets
  enable_dns_hostnames             = true
  enable_dns_support               = true
  default_vpc_enable_dns_hostnames = true
}
#Create security group for EC2
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.sg_prefix}-ec2-sg"
  description = "Security group for EC2 instance in Auto Scaling"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.ssh_whitelist
  ingress_rules       = ["ssh-tcp"]

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
      description              = "Allow HTTP from Load Balancer to EC2 instance"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

#Create security group for alb
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.sg_prefix}-alb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP to Load Balancer"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS to Load Balancer"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

#Create security group for db
module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.sg_prefix}-db-sg"
  description = "Security group for DB instance/cluster"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
      description              = "Allow connection from EC2 instance to DB"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

#Create security group for EFS
module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.sg_prefix}-efs-sg"
  description = "Security group for EFS service"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "nfs-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
      description              = "Allow connection from EC2 instance to EFS"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

#Create security group for elastic cache
module "cache_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.sg_prefix}-cache-sg"
  description = "Security group for Memcached"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "memcached-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
      description              = "Allow connection from EC2 instance to Memcached"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}
