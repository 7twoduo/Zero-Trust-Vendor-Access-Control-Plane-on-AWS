// Lambda functions placeholder
# LAMBDA LAMBDA LAMBDA - She sure is cold to me these days, like a lover that never meant to be.
data "archive_file" "app_bundle" { # This is just to convert the app directory into a zip file that can be uploaded to lambda.
  type        = "zip"
  source_dir  = "${path.module}/../app"
  output_path = "${path.module}/bundle.zip"
}

resource "aws_cloudwatch_log_group" "request_access" { # This is the Log group for the request access lambda function.
  name              = "/aws/lambda/${local.name_prefix}-request-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "approve_access" { # This is the Log group for the approve access lambda function.
  name              = "/aws/lambda/${local.name_prefix}-approve-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "revoke_access" { # This is the Log group for the revoke access lambda function.
  name              = "/aws/lambda/${local.name_prefix}-revoke-access"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_lambda_function" "request_access" {
  function_name = "${local.name_prefix}-request-access"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "request_access.lambda_handler"
  runtime       = var.lambda_runtime # This is the programming language that is used for the lambda function.

  filename         = data.archive_file.app_bundle.output_path # This is the path to the zip file that contains the code for the lambda fucntion.
  source_code_hash = data.archive_file.app_bundle.output_base64sha256 # This checks if the code has changes and updates the function based on those changes.
  timeout          = 30 # short timeout to limit resource use.
  memory_size      = 256 # limiting the size of the function to reduce blast radius in case of vulnerabilities.

  environment {
    variables = {
      TABLE_NAME                  = aws_dynamodb_table.access_requests.name # This is the name for the DynamoDB table that the lambda fucntion will use.
      EVIDENCE_BUCKET             = aws_s3_bucket.evidence.bucket # This is the name of the S3 bucket that holds the evidence of access request,approvals, timeouts, and denies for audits later on.
      EVIDENCE_KMS_KEY_ARN        = aws_kms_key.evidence.arn # This is the ARN of the KMS key used to encrypt the evidence in the S3 bucket.
      DEFAULT_DURATION_MINUTES    = tostring(var.default_access_duration_minutes)
      PROTECTED_ASSUME_ROLE_ARN   = aws_iam_role.partner_access_role.arn # This is the role that the lambda function sues to assign aws creds from to the vendors.
      ENVIRONMENT                 = var.env # This is like a tag to differentiate between prod, dev, staging, etc. 
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.request_access
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "approve_access" { # Same stuff as above but for the approve access function, which is responsible for granting access to the protected route when a request is approved. It will also create an entry in the evidence bucket with the details of the approval for audit purposes.
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

resource "aws_lambda_function" "revoke_access" { # Same stuff as above but for the revoke access function, which is responsible for revoking access to the protected route when a request is revoked or when the access duration expires. It will also create an entry in the evidence bucket with the details of the revocation for audit purposes. This function is triggered on a schedule using EventBridge to check for any approved requests that have expired and need to be revoked.
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
# This is the trigger for the revoke access lambda function. It uses Eventbridge to do this.
resource "aws_cloudwatch_event_rule" "revoke_schedule" {
  name                = "${local.name_prefix}-revoke-schedule"
  description         = "Runs the revoke Lambda on a schedule."
  schedule_expression = var.revoke_schedule_expression

  tags = local.common_tags
}
# This is the target for the EventBridge rule that triggers the revoke access lambda function on a schedule.
resource "aws_cloudwatch_event_target" "revoke_schedule" {
  rule      = aws_cloudwatch_event_rule.revoke_schedule.name
  target_id = "revoke-access-lambda"
  arn       = aws_lambda_function.revoke_access.arn
}
# This allows eventbridge to invoke the revoke access lambda function based on the schedule defined in the aws_cloudwatch_event_rule.revoke_schedule resource.
resource "aws_lambda_permission" "allow_eventbridge_revoke" {
  statement_id  = "AllowExecutionFromEventBridgeRevoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.revoke_access.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.revoke_schedule.arn
}