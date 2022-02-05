variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type = string
  default = "ON_DEMAND"
}

variable "desired_size" {
  type = number
}

variable "min_capacity" {
  type = number
  default = 1
}

variable "max_capacity" {
  type = number
  default = 5
}

variable "tags" {
  type = map(string)
}

variable "labels" {
  type = map(string)
}

variable "taints" {
  type = list
}

variable "node_group_name" {
  type = string
}

variable "release_version" {
  type = string
  default = "1.21.2-20210813"
}

variable "ami_type" {
  type = string
  default = "AL2_x86_64"
}