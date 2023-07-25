output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(local.linux_user_data, null)
}
