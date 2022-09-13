variable "ami_name" {
  type        = list(string)
  description = "Name of AMI"
}
variable "ami_owner" {
  type        = list(string)
  description = "Owner ID of AMI"
}
variable "project" {
  type        = string
  description = "Name tags of this project"
  default = ""
}
variable "vpc" {
  type        = any
  description = "Define value vpc id and public_subnets in module alb "
}
variable "lt_sg" {
  type        = any
  description = "Security group of launch tempplate"
}
variable "lb_sg" {
  type        = any
  description = "Security group of load balancer"
}
variable "vpc_zone_identifier" {
  type        = any
  description = "VPC's zones for auto scaling group"
}
variable "lt_instance_type" {
  type        = string
  description = "Launch template instance's type"
}
variable "key_name" {
  type        = string
  description = "Key pair of launch template"
}
variable "iam_instance_profile" {
  type        = string
  description = "IAM role for instances of launch template"
}
variable "desired_capacity" {
  type        = number
  description = "Desired capacity of ASG"
}
variable "min_size" {
  type        = number
  description = "Min size of intances of ASG"
}
variable "max_size" {
  type        = number
  description = "Max size of instances of ASG"
}
variable "efs_host" {
  type        = string
  description = "EFS dns hostname"
}
variable "db_name" {
  type        = string
  description = "Database name"
}
variable "db_hostname" {
  type        = string
  description = "Database hostname"
}
variable "db_username" {
  type        = string
  description = "Database master user"
}
variable "db_password" {
  type        = string
  description = "Database master password"
}
variable "wp_username" {
  type        = string
  description = "Wordpress admin username"
}
variable "wp_password" {
  type        = string
  description = "Wordpress admin password"
}
variable "wp_email" {
  type        = string
  description = "Wordpress admin email"
}

variable "lt_name" {
  type = string
  description = "Launch Template name"
}

variable "asg_name" {
  type = string
  description = "Auto Scaling Group name"
}

variable "alb_name" {
  type = string
  description = "Application Load Balancer name"
}

variable "kms_cmk_key" {
  type = string
  description = "KMS CMK id or arn"
}