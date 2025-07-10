variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "customer_buckets" {
  description = "Map of customer S3 bucket names to subfolders"
  type        = map(list(string))
}

variable "central_account_id" {
  description = "AWS Account ID of the central account for cross-account access"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {
    Application = "Campaign"
    OE          = "oneMarketing"
    Team        = "MarketingExecution"
    Use         = "DataImportExport"
  }
}
