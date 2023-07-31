locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_merged = { for k, v in var.node_groups : k => merge(
    {
      iam_role_arn            = var.default_iam_role_arn
      key_name                = ""
      launch_template_id      = null
      launch_template_version = "$Latest"
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
  ) }

  node_groups_temp = flatten([for k, v in local.node_groups_merged :
    [for index, subnet in var.private_subnets :
      { "${k}-${subnet.availability_zone}" = merge(
        v,
        {
          subnets          = [subnet.id]
          min_capacity     = ceil(v.min_capacity / length(var.private_subnets))
          max_capacity     = ceil(v.max_capacity / length(var.private_subnets))
          desired_capacity = ceil(v.desired_capacity / length(var.private_subnets))
          name             = "${v.name}-${subnet.availability_zone}-${subnet.id}"
          set_name         = "${v.name}"
          labels = merge(
            lookup(v, "labels", {}),
            { "topology.ebs.csi.aws.com/zone" = "${subnet.availability_zone}" }
          )
        },
        )
      } if contains(data.aws_ec2_instance_type_offerings.node_groups[k].locations, subnet.availability_zone)
    ]
  ])

  node_groups_expanded = zipmap(
    flatten(
      [for item in local.node_groups_temp : keys(item)]
    ),
    flatten(
      [for item in local.node_groups_temp : values(item)]
    )
  )

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

data "aws_ec2_instance_type_offerings" "node_groups" {
  for_each = local.node_groups_merged
  filter {
    name   = "instance-type"
    values = lookup(each.value, "instance_types")
  }

  location_type = "availability-zone"
}
