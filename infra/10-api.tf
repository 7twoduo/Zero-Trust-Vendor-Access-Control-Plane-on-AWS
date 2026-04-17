// API Gateway / API resources placeholder
#This is the log group for the API Gateway access logs.
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${local.name_prefix}-http-api"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}
# This is the API Gateway resource that will use HTTP protocol for all it's paths.
resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}
# This adds the lambda function request access as a backend that I can point a route to it later in the api gateway.
resource "aws_apigatewayv2_integration" "request_access" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.request_access.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}
# This adds the lambda function approve access as a backend that I can point a route to it later in the api gateway.
resource "aws_apigatewayv2_integration" "approve_access" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.approve_access.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}
# This is the route for the request access api path. When a request is made to the /request path with a POST method, it will trigger the request access lambda function.
resource "aws_apigatewayv2_route" "request_access" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /request"
  target    = "integrations/${aws_apigatewayv2_integration.request_access.id}"

  authorization_type = "NONE"
}
# This is the route for the approve access api path. When a request is made to the /approve path with a POST method, it will trigger the approve access lambda function.
resource "aws_apigatewayv2_route" "approve_access" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /approve"
  target    = "integrations/${aws_apigatewayv2_integration.approve_access.id}"

  authorization_type = "NONE"
}
# This is the route for the protected partner resource api path. When a request is made to the /partner/resource path with a GET method, it will trigger the request access lambda function.
resource "aws_apigatewayv2_route" "protected_partner_resource" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /partner/resource"
  target    = "integrations/${aws_apigatewayv2_integration.request_access.id}"

  authorization_type = "AWS_IAM"
}
# This is the stage that is hit before you hit the part of the API Gateway that triggers the lambda functions. It also defines the access log settings for the API Gateway, which will send access logs to the CloudWatch log group defined in the aws_cloudwatch_log_group.api_gateway resource. The log format is defined as a JSON object that includes useful information about each request, such as the request ID, source IP, request time, HTTP method, route key, status code, protocol, and response length. This information can be used for monitoring and troubleshooting the API Gateway.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn

    format = jsonencode({ # This extracts useful information from the API Gateway access logs and formats it as JSON for easier analysis in CloudWatch Logs Insights.
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
# This allows the API Gateway to call the lambda function for the request access route.
resource "aws_lambda_permission" "allow_apigw_request_access" {
  statement_id  = "AllowExecutionFromApiGatewayRequestAccess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_access.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
# This allows the API Gateway to call the lambda function for the approve access route.
resource "aws_lambda_permission" "allow_apigw_approve_access" {
  statement_id  = "AllowExecutionFromApiGatewayApproveAccess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.approve_access.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}