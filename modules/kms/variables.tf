variable "general_prefix" {
  description = "prefix for resouce name or description"
  type        = string
}
variable "deletion_window_in_days" {
  description = "number of day to keep kms key after deletion"
  type        = number
  default     = 7
}
