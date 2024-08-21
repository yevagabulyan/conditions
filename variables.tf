# Define providers with aliases
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}


variable "environment" {
  type    = string
  default = "production"
}

variable "region_list" {
  type    = list(string)
  default = ["us-east-1", "us-west-1", "eu-central-1"]
}

variable "create_buckets" {
  type    = bool
  default = true
}

variable "allowed_regions" {
  type    = list(string)
  default = ["us-east-1", "eu-central-1"]
}


locals {
  uppercase_environment = upper(var.environment)
  lowercase_environment = lower(var.environment)

  bucket_names = { for region in var.region_list : region => "${local.lowercase_environment}-bucket-${region}" }

  filtered_regions = [
    for region in var.region_list : region
    if contains(var.allowed_regions, region) && var.create_buckets
  ]
}

module "s3_buckets"{
  for_each = { for region in local.filtered_regions : 
               region => local.bucket_names[region] 
             }

  source = "./modules"
  
  provider_alias = each.key
  bucket_name    = each.value
}

