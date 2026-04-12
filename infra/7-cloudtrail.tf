// CloudTrail configuration placeholder
# This creates a CloudTrail trail that will log all management events in the account and deliver the logs to the cloudtrail S3 bucket that we created earlier. CloudTrail is a critical component of our security and compliance strategy, as it provides visibility into all API activity in the account, which is essential for auditing and incident response. By including global service events, we ensure that we have visibility into important events that occur in global services like IAM, which are not region-specific.
resource "aws_cloudtrail" "main" {
  name                          = "${local.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]

  tags = local.common_tags
}