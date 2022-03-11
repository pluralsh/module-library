variable "cluster_name" {
  type = string
  documentation = "name of the cluster that can assume the role"
}

variable "role_name" {
  type = string
  documentation = "name of the role"
}

variable "namespace" {
  type = string
  documentation = "namespace you can assume the role in"
}

variable "serviceaccount" {
  type = string
  documentation = "service account that can assume the role"
}

variable "policy_json" {
  type = string
  documentation = "json of the policy document for the role"
}