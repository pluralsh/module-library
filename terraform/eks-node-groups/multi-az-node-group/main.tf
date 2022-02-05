data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_node_groups" "cluster" {
  cluster_name    = var.cluster_name
}

data "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = tolist(data.aws_eks_node_groups.cluster.names)[0]
}

resource "aws_eks_node_group" "gpu_inf_small" {
  cluster_name    = data.aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = data.aws_eks_node_group.main.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  release_version = var.ami_release_version
  disk_size       = 50
  capacity_type   = var.capacity_type

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_capacity
    max_size     = var.max_capacity
  }

  tags   = var.tags
  labels = var.labels

  dynamic "taint" {
    for_each = each.value["taints"]
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value")
      effect = taint.value.effect
    }
  }
}