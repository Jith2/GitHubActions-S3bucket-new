output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_policy" {
  value = aws_s3_bucket_policy.central_user_access.policy
}
