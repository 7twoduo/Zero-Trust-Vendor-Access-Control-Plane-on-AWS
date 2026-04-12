// API Gateway / API resources placeholder
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${local.name_prefix}-http-api"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "request_access" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.request_access.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_integration" "approve_access" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.approve_access.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "request_access" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /request"
  target    = "integrations/${aws_apigatewayv2_integration.request_access.id}"

  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "approve_access" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /approve"
  target    = "integrations/${aws_apigatewayv2_integration.approve_access.id}"

  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "protected_partner_resource" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /partner/resource"
  target    = "integrations/${aws_apigatewayv2_integration.request_access.id}"

  authorization_type = "AWS_IAM"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn

    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_apigw_request_access" {
  statement_id  = "AllowExecutionFromApiGatewayRequestAccess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_access.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_approve_access" {
  statement_id  = "AllowExecutionFromApiGatewayApproveAccess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.approve_access.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}