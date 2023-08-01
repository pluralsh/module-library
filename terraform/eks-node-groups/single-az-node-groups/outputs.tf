output "node_groups" {
  description = "Outputs from EKS node groups. Map of maps, keyed by `var.node_groups` keys. See `aws_eks_node_group` Terraform documentation for values"
  value       = aws_eks_node_group.workers
}

output "aws_auth_roles" {
  description = "Roles for use in aws-auth ConfigMap"
  value = [
    for k, v in local.node_groups_expanded : {
      worker_role_arn = lookup(v, "iam_role_arn", var.default_iam_role_arn)
      platform        = "linux"
    }
  ]
}

output "ng_merged" {
  value = local.node_groups_merged
}

output "ng_temp" {
  value = local.node_groups_temp
}

output "ng_expanded" {
  value = local.node_groups_expanded
}

output "user_data_kubelet_extra_args" {
  value = module.launch_templates[*].user_data_kubelet_extra_args
}

output "kubelet_extra_args" {
  value = module.launch_templates[*].kubelet_extra_args
}

output "k8s_labels" {
  value = module.launch_templates[*].k8s_labels
}

output "k8s_taints" {
  value = module.launch_templates[*].k8s_taints
}
