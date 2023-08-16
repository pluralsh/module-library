output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(local.linux_user_data, null)
}

output "kubelet_extra_args" {
  description = "Extra arguments to pass to kubelet"
  value       = try(local.kubelet_extra_args, null)
}
