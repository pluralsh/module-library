output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.this.id, null)
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.this.arn, null)
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.this.latest_version, null)
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = try(aws_launch_template.this.name, null)
}

output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(module.user_data.user_data, null)
}

output "user_data_kubelet_extra_args" {
  value = module.user_data.kubelet_extra_args
}

output "kubelet_extra_args" {
  value = var.kubelet_extra_args
}

output "k8s_labels" {
  value = var.k8s_labels
}

output "k8s_taints" {
  value = var.k8s_taints
}
