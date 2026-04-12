// Terraform outputs placeholder
output "api_endpoint" {
  description = "Base HTTP API endpoint."
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "request_url" {
  description = "Access request endpoint."
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/request"
}

output "approve_url" {
  description = "Approval endpoint."
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/approve"
}

output "protected_partner_resource_url" {
  description = "Protected partner resource endpoint."
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/partner/resource"
}

output "evidence_bucket_name" {
  description = "Evidence S3 bucket."
  value       = aws_s3_bucket.evidence.bucket
}

output "cloudtrail_bucket_name" {
  description = "CloudTrail S3 bucket."
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "dynamodb_table_name" {
  description = "Access request DynamoDB table."
  value       = aws_dynamodb_table.access_requests.name
}

output "partner_access_role_arn" {
  description = "Role that gets assumed for protected resource access."
  value       = aws_iam_role.partner_access_role.arn
}

output "kms_key_arn" {
  description = "KMS key used for evidence encryption."
  value       = aws_kms_key.evidence.arn
}