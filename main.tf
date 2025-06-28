provider "aws" {
  region = var.aws_region
}

module "customer_buckets" {
  source             = "./modules/s3_bucket"
  for_each           = var.customer_buckets
  bucket_name        = each.key
  subfolders         = each.value
  tags               = var.tags
  central_account_id = var.central_account_id
  iam_user_name      = "tu-${each.key}"
}

output "bucket_names" {
  value = {
    for k, m in module.customer_buckets : k => m.bucket_name
  }
}

terraform {
  backend "s3" {
    bucket       = "statefile-campaign-dev"
    key          = "Statefile-campaign/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
  }
}
