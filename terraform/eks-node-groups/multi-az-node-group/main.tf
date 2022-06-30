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

resource "aws_eks_node_group" "nodes" {
  cluster_name         = data.aws_eks_cluster.cluster.name
  node_group_name      = var.node_group_name
  node_role_arn        = data.aws_eks_node_group.main.node_role_arn
  subnet_ids           = var.subnet_ids
  instance_types       = var.instance_types
  disk_size            = 50
  capacity_type        = var.capacity_type
  release_version      = var.release_version
  force_update_version = true
  ami_type             = var.ami_type

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_capacity
    max_size     = var.max_capacity
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  tags   = var.tags
  labels = var.labels

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value")
      effect = taint.value.effect
    }
  }
}

resource "aws_autoscaling_group_tag" "labels" {
  for_each = [for key, value in var.labels : { key = key, value = value }]

  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/${each.value.key}"
    value               = each.value.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "taints" {
  for_each = var.taints

  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name

  tag {
    key = "k8s.io/cluster-autoscaler/node-template/taint/${each.value.key}"
    # The cluster autoscaler expects a tag of <taint>:NoSchedule|NoExecute|PreferNoSchedule
    # https://github.com/kubernetes/autoscaler/blob/a49804544346b2e3690769f1482b0e7442ea457d/cluster-autoscaler/cloudprovider/aws/aws_manager.go#L451
    # but on our node pools the effect needs to be NO_EXECUTE, NO_SCHEDULE, PREFER_NO_SCHEDULE
    # so this abomination of replace, title and lower transforms them from the ENUM style to
    # their TitleCase variant
    value               = each.value.value != "" ? "${each.value.value}:${replace(title(replace(lower(each.value.effect), "_", " ")), " ", "")}" : replace(title(replace(lower(each.value.effect), "_", " ")), " ", "")
    propagate_at_launch = true
  }
}
