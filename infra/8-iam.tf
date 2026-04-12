// IAM resources placeholder
# This IAM policy is to be attached to a lambda execution role, and it grants the necessary permissions for the lambda function to perform its tasks. This includes permissions to write logs to CloudWatch, access the DynamoDB table for managing access requests, interact with the S3 evidence bucket for storing and retrieving evidence, use the KMS key for encrypting and decrypting data in the evidence bucket, and assume the partner access role when a partner needs to invoke a protected route. By defining this policy, we ensure that our lambda function has the appropriate permissions to operate securely and effectively within our architecture.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# This creates the IAM role for the lambda function, which will be assumed by the lambda service when executing the function. The assume role policy allows the lambda service to assume this role, and we will attach the inline policy defined above to this role to grant it the necessary permissions.
resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name_prefix}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}
# This creates an inline policy that will be attached to a lambda role and grants it permissions to interact with CloudWatch Logs, DynamoDB, S3, KMS, and to assume the partner access role. This policy is essential for the lambda function to perform its tasks, such as logging, managing access requests, handling evidence in S3, and assuming roles for partner access when needed.
data "aws_iam_policy_document" "lambda_inline" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]

    resources = [
      aws_dynamodb_table.access_requests.arn
    ]
  }

  statement {
    sid    = "EvidenceBucketAccess"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.evidence.arn,
      "${aws_s3_bucket.evidence.arn}/*"
    ]
  }

  statement {
    sid    = "UseKmsForEvidence"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.evidence.arn
    ]
  }

  statement {
    sid    = "AssumePartnerAccessRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.partner_access_role.arn
    ]
  }
}
# This attaches the inline policy to the lambda execution role, which is necessary for the lambda function to have the permissions defined in the policy. By attaching this policy, we ensure that our lambda function can perform its tasks securely and effectively within our architecture.
resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-lambda-inline"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_inline.json
}
# This 
data "aws_iam_policy_document" "partner_access_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_exec.arn]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "partner_access_role" {
  name               = "${local.name_prefix}-partner-access"
  assume_role_policy = data.aws_iam_policy_document.partner_access_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "partner_access_invoke" {
  statement {
    sid    = "InvokeProtectedRoute"
    effect = "Allow"

    actions = [
      "execute-api:Invoke"
    ]

    resources = [
      "${aws_apigatewayv2_api.main.execution_arn}/${aws_apigatewayv2_stage.default.name}/GET/partner/resource"
    ]
  }
}

resource "aws_iam_role_policy" "partner_access_invoke" {
  name   = "${local.name_prefix}-partner-invoke-protected-route"
  role   = aws_iam_role.partner_access_role.id
  policy = data.aws_iam_policy_document.partner_access_invoke.json
}