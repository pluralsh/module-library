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

output "private_key_id" {
  description = "Unique identifier for this resource: hexadecimal representation of the SHA1 checksum of the resource"
  value       = try(tls_private_key.this[0].id, "")
}

output "private_key_openssh" {
  description = "Private key data in OpenSSH PEM (RFC 4716) format"
  value       = try(trimspace(tls_private_key.this[0].private_key_openssh), "")
  sensitive   = true
}

output "private_key_pem" {
  description = "Private key data in PEM (RFC 1421) format"
  value       = try(trimspace(tls_private_key.this[0].private_key_pem), "")
  sensitive   = true
}
