resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_expanded

  node_group_name = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))

  cluster_name  = var.cluster_name
  node_role_arn = each.value["iam_role_arn"]
  subnet_ids    = each.value["subnets"]

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  ami_type        = lookup(each.value, "ami_type", null)
  disk_size       = lookup(each.value, "disk_size", null)
  instance_types  = lookup(each.value, "instance_types", null)
  release_version = lookup(each.value, "ami_release_version", null)
  capacity_type   = lookup(each.value, "capacity_type", null)

  dynamic "remote_access" {
    for_each = each.value["key_name"] != "" ? [{
      ec2_ssh_key               = each.value["key_name"]
      source_security_group_ids = lookup(each.value, "source_security_group_ids", [])
    }] : []

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  dynamic "launch_template" {
    for_each = each.value["launch_template_id"] != null ? [{
      id      = each.value["launch_template_id"]
      version = each.value["launch_template_version"]
    }] : []

    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  version = lookup(each.value, "version", null)

  labels = each.value["labels"]

  dynamic "taint" {
    for_each = each.value["taints"]
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value")
      effect = taint.value.effect
    }
  }

  tags = each.value["tags"]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  depends_on = [var.ng_depends_on]
}

resource "aws_autoscaling_group_tag" "labels" {
  for_each = local.nodegroup_labels

  autoscaling_group_name = aws_eks_node_group.workers[each.value.pool].resources[0].autoscaling_groups[0].name

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/${each.value.key}"
    value               = each.value.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "taints" {
  for_each = local.nodegroup_taints

  autoscaling_group_name = aws_eks_node_group.workers[each.value.pool].resources[0].autoscaling_groups[0].name

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
