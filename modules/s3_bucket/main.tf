resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_object" "folders" {
  for_each = toset(var.subfolders)
  bucket   = aws_s3_bucket.this.id
  key      = each.value
  content  = ""
}

locals {
  central_user_arn = "arn:aws:iam::038697395377:user/tu-${var.bucket_name}"
}
 
resource "aws_s3_bucket_policy" "central_user_access" {
  bucket = aws_s3_bucket.this.id
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCentralIAMUserAccess",
        Effect    = "Allow",
        Principal = {
          AWS = local.central_user_arn
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "expire_objects" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.subfolders
    content {
      id     = "expire-objects-30-days-${replace(rule.value, "/", "-")}"
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
