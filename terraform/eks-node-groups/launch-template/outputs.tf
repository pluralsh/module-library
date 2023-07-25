output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.this[0].id, null)
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.this[0].arn, null)
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.this[0].latest_version, null)
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = try(aws_launch_template.this[0].name, null)
}
