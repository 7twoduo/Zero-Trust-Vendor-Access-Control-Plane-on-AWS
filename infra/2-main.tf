// Terraform main configuration placeholder

# this is the datablock to get my account id
data "aws_caller_identity" "current" {}
# This is the datablock to get the current region
data "aws_region" "current" {}
# This creates a random string that I can assign to anything
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

locals {
  name_prefix = lower("${var.project_name}-${var.env}") # this creates a standard naming convention for all resources, making it easier to identify them in the AWS console

  common_tags = merge( # This is very useful as it creates, in one place, the tags that I want to apply to all resources. This way, if I want to change a tag value, I only have to do it in one place.
    {
      Project     = var.project_name
      Environment = var.env
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  evidence_bucket_name   = lower("${local.name_prefix}-evidence-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}") #  This is the evidence bucket name
  cloudtrail_bucket_name = lower("${local.name_prefix}-trail-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}")    #this is the cloudtrail bucket name
}