variable "project" {
  type    = string
  default = ""
}

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

variable "db_identifier" {
  type        = string
  description = "Database Identifier, the Name for database instance or cluster"
}
variable "db_name" {
  type = string
}
variable "master_username" {
  type = string
}
variable "master_password" {
  type = string
}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "instance_class" {
  type = string
}
variable "subnet_ids_group" {
  type = list(string)
}
variable "allocated_storage" {
  type = number
}
variable "db_password_rotation_days" {
  type        = number
  description = "Password RDS rotation day"
}
variable "vpc_id" {
  type        = string
  description = "vpc id for lambda function and future use"
}

variable "schedule_role" {
  type        = string
  default     = "cron(0 0 ? * WED,FRI *)"
  description = "Schedule role for backup plan"
}

variable "delete_after" {
  type        = number
  default     = 7
  description = "number of days to delete the backup"
}
