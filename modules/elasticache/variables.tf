variable "project" {
  type        = string
  description = "Name tags of this project"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids of memcached"
}
variable "engine_version" {
  type        = string
  description = "Engine version"
}
variable "security_group_ids" {
  type        = any
  description = "Security group id of memcached"
}
variable "engine" {
  type        = string
  description = "Engine"
}
variable "node_type" {
  type        = string
  description = "Node type"
}
variable "num_cache_nodes" {
  type        = number
  description = "Number of cache nodes"
}
variable "parameter_group_name" {
  type        = string
  description = "Parameter group name"
}
variable "port" {
  type        = number
  description = "Port of memcached"
}
