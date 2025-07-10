provider "aws" {
  region = var.aws_region
}

variable "customer_buckets" {
  description = "Map of customer S3 bucket names to subfolders"
  type        = map(list(string))
}

module "customer_buckets" {
  source      = "./modules/s3_bucket"
  for_each    = var.customer_buckets
  bucket_name = each.key
  subfolders  = each.value
  tags        = var.tags
}

output "bucket_policies" {
  value = {
    for k, m in module.customer_buckets : k => m.bucket_policy
  }
}
  
terraform {
  backend "s3" {
    bucket         = "statefile-campaign-dev"
    key            = "Statefile-campaign/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
