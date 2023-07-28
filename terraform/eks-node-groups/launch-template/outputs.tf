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
