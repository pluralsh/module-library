variable "bucket_names" {
  type = list(string)
}

variable "acl" {
  type    = string
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

variable "bucket_tags" {
  type        = map(string)
  description = "tags to apply to the buckets"
  default     = {}
}

variable "enable_versioning" {
  type    = bool
  default = false
}
