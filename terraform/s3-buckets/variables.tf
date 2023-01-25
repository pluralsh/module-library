variable "bucket_names" {
  type = list(string)
}

variable "acl" {
  type = string
  default = "private"
}

variable "policy_prefix" {
  type = string
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "If true, the bucket will be deleted even if it contains objects."
}
