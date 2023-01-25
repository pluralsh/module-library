resource "aws_s3_bucket" "bucket" {
  for_each      = toset(var.bucket_names)
  bucket        = each.key
  acl           = var.acl
  force_destroy = var.force_destroy
  tags          = var.bucket_tags

  versioning {
    enabled = var.enable_versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_policy" "iam_policy" {
  name_prefix = var.policy_prefix
  description = "policy for ${var.policy_prefix} s3 access"
  policy      = data.aws_iam_policy_document.admin.json
}

data "aws_iam_policy_document" "admin" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = ["s3:*"]

    resources = concat(
      [for bucket in var.bucket_names : "arn:aws:s3:::${bucket}"],
      [for bucket in var.bucket_names : "arn:aws:s3:::${bucket}/*"]
    )
  }
}
