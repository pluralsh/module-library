terraform {
  required_providers {
    minio = {
      source = "pluralsh/minio"
      version = "1.1.3"
    }
  }
}

data "kubernetes_secret" "minio" {
  metadata {
    name = var.minio_root_secret
    namespace = var.minio_namespace
  }
}

provider "minio" {
  minio_server = var.minio_server
  minio_region = var.minio_region
  minio_access_key = data.kubernetes_secret.minio.data.rootUser
  minio_secret_key = data.kubernetes_secret.minio.data.rootPassword
  minio_ssl = "true"
}