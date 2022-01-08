resource "aws_s3_bucket" "bucket" {
  for_each      = var.bucket_names
  bucket        = each.key
  acl           = var.acl
  force_destroy = true
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
