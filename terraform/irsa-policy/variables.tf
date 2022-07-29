variable "cluster_name" {
  type = string
  description = "name of the cluster that can assume the role"
}

variable "role_name" {
  type = string
  description = "name of the role"
}

variable "namespace" {
  type = string
  description = "namespace you can assume the role in"
}

variable "serviceaccount" {
  type = string
  description = "service account that can assume the role"
}

variable "policy_json" {
  type = string
  description = "json of the policy document for the role"
}