resource "minio_s3_bucket" "airbyte" {
  for_each = to_set(var.bucket_names)
  bucket   = each.key
  acl      = var.acl
}


resource "minio_iam_policy" "admin" {
  name   = "minio-${var.user_name}"
  policy = data.minio_iam_policy_document.airbyte.json
}

resource "minio_iam_user" "user" {
  name = var.user_name
}

resource "minio_iam_user_policy_attachment" "admin" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.admin.id
}

data "minio_iam_policy_document" "admin" {
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
