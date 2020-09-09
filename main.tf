data "aws_region" "default" {}
data "aws_caller_identity" "default" {}

resource "aws_api_gateway_rest_api" "api" {
  name = var.name
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = var.stage_name
  depends_on = [
    aws_api_gateway_integration.request_method_integration,
    aws_api_gateway_integration_response.response_method_integration
  ]
  variables = {
    deployed_at = formatdate("YYYYMMDDhhmmss", timestamp())
  }
  lifecycle {
    create_before_destroy = true
  }
}

//resource "aws_api_gateway_resource" "proxy" {
//  rest_api_id = aws_api_gateway_rest_api.api.id
//  parent_id = aws_api_gateway_rest_api.api.root_resource_id
//  path_part = "{proxy+}"
//}

resource "aws_api_gateway_method" "request_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id # aws_api_gateway_resource.proxy.id
  http_method = var.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id # aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.request_method.http_method
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${data.aws_region.default.name}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id # aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_integration.request_method_integration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id # aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method_response.response_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = var.lambda_arn
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:${aws_api_gateway_rest_api.api.id}/*"
  depends_on = [
    aws_api_gateway_rest_api.api
    #aws_api_gateway_resource.proxy
  ]
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name = var.custom_domain
  certificate_arn = var.custom_domain_certificate_arn
}

resource "aws_api_gateway_base_path_mapping" "domain" {
  api_id = aws_api_gateway_rest_api.api.id
  stage_name = aws_api_gateway_deployment.deployment.stage_name
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}