module "bucket" {
  for_each = var.bucket_names
  source = "./admin-bucket"
  bucket_name = each.key
  project_id = var.project_id
  service_account_email = var.service_account_email
}