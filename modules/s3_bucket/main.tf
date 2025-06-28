locals {
  all_folders = distinct(flatten([
    for folder in var.subfolders : [
      for i in range(length(split("/", trim(folder, "/")))) :
        "${join("/", slice(split("/", trim(folder, "/")), 0, i + 1))}/"
    ]
  ]))
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true
  tags   = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(local.all_folders) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = local.all_folders
    content {
      id     = "expire-objects-30-days-${replace(trim(rule.value, "/"), "/", "-")}"
      status = "Enabled"
      filter {
        prefix = rule.value
      }
      expiration {
        days = 30
      }
    }
  }
}

resource "aws_s3_bucket_policy" "allow_central_user" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.central_user_access.json
}

data "aws_iam_policy_document" "central_user_access" {
  statement {
    sid    = "AllowCentralAccountUserAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.central_account_id}:user/${var.iam_user_name}"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_s3_object" "subfolders" {
  for_each = toset(local.all_folders)
  bucket   = aws_s3_bucket.this.id
  key      = each.value
  content  = ""
}