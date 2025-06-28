variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "subfolders" {
  description = "List of subfolders to create in the bucket"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "central_account_id" {
  description = "AWS Account ID of the central account for cross-account access"
  type        = string
}

variable "iam_user_name" {
  description = "IAM user name in the central account to allow access"
  type        = string
}