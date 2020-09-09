output "http_method" {
  value = aws_api_gateway_integration_response.response_method_integration.http_method
}

output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "cloudfront_domain_name" {
  value = aws_api_gateway_domain_name.domain.cloudfront_domain_name
}

output "cloudfront_zone_id" {
  value = aws_api_gateway_domain_name.domain.cloudfront_zone_id
}