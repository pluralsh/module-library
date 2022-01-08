resource "google_storage_bucket" "bucket" {
  name = var.bucket_name
  project = var.project_id
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "admin-access" {
  bucket = google_storage_bucket.bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${var.service_account_email}"

  depends_on = [
    google_storage_bucket.bucket,
  ]
}