variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "VPC's cidr"
}
variable "public_subnets" {
  type        = list(string)
  description = "VPC's public subnets"
}

variable "ssh_whitelist" {
  type        = list(string)
  description = "Whitelist IP for SSH connection to EC2 instance"
  default     = ["0.0.0.0/0"]
}

variable "sg_prefix" {
  type        = string
  description = "Prefix name for Security Group"
}
