variable "bucket_names" {
  type = list(string)
}

variable "service_account_email" {
  type = string
}

variable "project_id" {
  type = string
}

variable "location" {
  type = string
  default = "US"
}
