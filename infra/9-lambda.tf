// Lambda functions placeholder
#
data "archive_file" "app_bundle" {
  type        = "zip"
  source_dir  = "${path.module}/../app"
  output_path = "${path.module}/bundle.zip"
}

resource "aws_cloudwatch_log_group" "request_access" {
  name              = "/aws/lambda/${local.name_prefix}-request-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "approve_access" {
  name              = "/aws/lambda/${local.name_prefix}-approve-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "revoke_access" {
  name              = "/aws/lambda/${local.name_prefix}-revoke-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_lambda_function" "request_access" {
  function_name = "${local.name_prefix}-request-access"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "request_access.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.app_bundle.output_path
  source_code_hash = data.archive_file.app_bundle.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME                  = aws_dynamodb_table.access_requests.name
      EVIDENCE_BUCKET             = aws_s3_bucket.evidence.bucket
      EVIDENCE_KMS_KEY_ARN        = aws_kms_key.evidence.arn
      DEFAULT_DURATION_MINUTES    = tostring(var.default_access_duration_minutes)
      PROTECTED_ASSUME_ROLE_ARN   = aws_iam_role.partner_access_role.arn
      ENVIRONMENT                 = var.env
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.request_access
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "approve_access" {
  function_name = "${local.name_prefix}-approve-access"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "approve_access.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.app_bundle.output_path
  source_code_hash = data.archive_file.app_bundle.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME                = aws_dynamodb_table.access_requests.name
      EVIDENCE_BUCKET           = aws_s3_bucket.evidence.bucket
      EVIDENCE_KMS_KEY_ARN      = aws_kms_key.evidence.arn
      DEFAULT_DURATION_MINUTES  = tostring(var.default_access_duration_minutes)
      PROTECTED_ASSUME_ROLE_ARN = aws_iam_role.partner_access_role.arn
      ENVIRONMENT               = var.env
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.approve_access
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "revoke_access" {
  function_name = "${local.name_prefix}-revoke-access"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "revoke_access.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.app_bundle.output_path
  source_code_hash = data.archive_file.app_bundle.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME           = aws_dynamodb_table.access_requests.name
      EVIDENCE_BUCKET      = aws_s3_bucket.evidence.bucket
      EVIDENCE_KMS_KEY_ARN = aws_kms_key.evidence.arn
      ENVIRONMENT          = var.env
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.revoke_access
  ]

  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "revoke_schedule" {
  name                = "${local.name_prefix}-revoke-schedule"
  description         = "Runs the revoke Lambda on a schedule."
  schedule_expression = var.revoke_schedule_expression

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "revoke_schedule" {
  rule      = aws_cloudwatch_event_rule.revoke_schedule.name
  target_id = "revoke-access-lambda"
  arn       = aws_lambda_function.revoke_access.arn
}

resource "aws_lambda_permission" "allow_eventbridge_revoke" {
  statement_id  = "AllowExecutionFromEventBridgeRevoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.revoke_access.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.revoke_schedule.arn
}