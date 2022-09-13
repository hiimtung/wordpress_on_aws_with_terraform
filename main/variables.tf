# General
variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project" {
  type        = string
  default     = "wptf"
  description = "Project name, use for tagging and naming resource"
}

variable "environment" {
  type        = string
  description = "Define the environment of resource, use for tagging"
  default     = "product"
}

variable "ssh_whitelist" {
  type = list(string)
  description = "Whitelist IP for SSH connection to EC2 instance"
  default = [ "0.0.0.0/0" ]
}

#Networking
variable "nw_vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "172.16.0.0/16"
}
variable "nw_public_subnets" {
  type        = list(string)
  description = "List of Public subnets"
  default     = ["172.16.2.0/23", "172.16.4.0/23", "172.16.6.0/23"]
}
# #Autoscaling
variable "asg_instance_type" {
  type        = string
  description = "Instance type of ASG"
  default     = "t2.micro"
}
variable "asg_iam_instance_profile" {
  type        = string
  description = "Iam role attached to ASG instance"
  default     = "S3-CF-SSM-role"
}
variable "asg_desired_capacity" {
  type        = number
  description = "Number of ASG's instances initialized"
  default     = 2
}
variable "asg_min_size" {
  type        = number
  description = "minimum number of ASG's instances"
  default     = 2
}
variable "asg_max_size" {
  type        = number
  description = "maximum number of ASG's instances"
  default     = 2
}
variable "lt_ami_name" {
  type    = list(string)
  default = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2"]
}
variable "lt_ami_owner" {
  type    = list(string)
  default = ["137112412989"]
}
variable "lt_key_name" {
  type    = string
  default = "wp-keypair"
}
variable "asg_wp_username" {
  type        = string
  description = "Wordpress admin's username"
  default     = "wordpressadmin"
}
variable "asg_wp_password" {
  type        = string
  description = "Wordpress admin's password"
  default     = "Zxcvb!@#%"
}
variable "asg_wp_email" {
  type        = string
  description = "Wordpress admin's email"
  default     = "admin@example.com"
}
#Database
variable "enabled_aurora" {
  type        = bool
  description = "Set true if use Aurora. Default is False"
  default     = false
}
variable "db_cluster_size" {
  type        = number
  description = "Number of instance for Aurora cluster, ignore if use RDS"
  default     = 2
}
variable "db_instance_class" {
  type    = string
  default = "db.t2.small"
}
variable "db_engine" {
  type    = string
  default = "aurora-mysql"
}
variable "db_name" {
  type    = string
  default = "wordpressdb"
}
variable "db_username" {
  type    = string
  default = "admin"
}
variable "db_password" {
  type    = string
  default = "doesnotmatter"
}
variable "db_password_rotation_days" {
  type        = number
  description = "Password RDS rotation day"
  default     = 30
}
variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage. RDS only"
  default     = 20
}
#S3
variable "s3_bucket" {
  type    = string
  default = "wordpress-s3-terraform"
}
variable "s3_acl" {
  type    = string
  default = "private"
}
#Elastic cache
variable "cache_engine" {
  type    = string
  default = "memcached"
}
variable "cache_engine_version" {
  type    = string
  default = "1.6.12"
}
variable "cache_node_type" {
  type    = string
  default = "cache.t2.micro"
}
variable "cache_num_cache_nodes" {
  type    = number
  default = 1
}
variable "cache_parameter_group_name" {
  type    = string
  default = "default.memcached1.6"
}
variable "cache_port" {
  type    = number
  default = 11211
}
