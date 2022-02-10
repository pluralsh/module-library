locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      iam_role_arn            = var.default_iam_role_arn
      key_name                = ""
      launch_template_id      = null
      launch_template_version = "$Latest"
      subnets = var.private_subnet_ids
      labels = merge(
        lookup(var.node_groups_defaults, "k8s_labels", {}),
        lookup(var.node_groups[k], "k8s_labels", {})
      )
      taints = concat(
        lookup(var.node_groups_defaults, "k8s_taints", []),
        lookup(var.node_groups[k], "k8s_taints", [])
      )
      tags = merge(
        var.tags,
        lookup(var.node_groups_defaults, "additional_tags", {}),
        lookup(var.node_groups[k], "additional_tags", {}),
      )
    },
    var.node_groups_defaults,
    v,
  )}

  nodegroup_labels = { for obj in flatten([
    for name, attr in local.node_groups_expanded : [
      for label, value in attr.labels : { pool = name, key = label, value = value }
    ]
  ]) : format("%s/%s", obj.pool, obj.key) => obj }

  nodegroup_taints = { for obj in flatten([
    for name, attr in local.node_groups_expanded : [
      for taint in attr.taints : { pool = name, key = taint.key, value = taint.value, effect = taint.effect }
    ]
  ]) : format("%s/%s", obj.pool, obj.key) => obj }
}
