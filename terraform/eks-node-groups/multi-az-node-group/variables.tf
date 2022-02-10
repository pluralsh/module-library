variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
}

variable "default_iam_role_arn" {
  description = "ARN of the default IAM worker role to use if one is not specified in `var.node_groups` or `var.node_groups_defaults`"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "node_groups_defaults" {
  description = "map of maps of node groups to create. See \"`node_groups` and `node_groups_defaults` keys\" section in README.md for more details"
  type        = any
}

variable "node_groups" {
  description = "Map of maps of `eks_node_groups` to create. See \"`node_groups` and `node_groups_defaults` keys\" section in README.md for more details"
  type        = any
  default     = {}
}

# Hack for a homemade `depends_on` https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
# Will be removed in Terraform 0.13 with the support of module's `depends_on` https://github.com/hashicorp/terraform/issues/10462
variable "ng_depends_on" {
  description = "List of references to other resources this submodule depends on"
  type        = any
  default     = null
}

variable "set_desired_size" {
  description = "allow desired size to be pinned for the node group"
  type = bool
  default = false
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS worker groups."
  type        = list(string)
  default     = []
}
