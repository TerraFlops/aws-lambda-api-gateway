module "api" {
  source = "git::https://github.com/TerraFlops/aws-api-gateway?ref=v1.0"
  name = module.lambda.name
  method = "ANY"
  lambda = module.lambda.name
  lambda_arn = module.lambda.arn
  stage_name = var.stage_name
  custom_domain = var.custom_domain
  custom_domain_certificate_arn = var.custom_domain_certificate_arn
}

module "lambda" {
  source = "git::https://github.com/TerraFlops/aws-lambda?ref=v1.0"
  filename = var.filename
  description = var.description
  function_name = var.function_name
  handler = var.handler
  runtime = var.runtime
  role = var.iam_role_arn
  memory = var.memory
  subnet_ids = var.subnet_ids
  security_group_ids = var.security_group_ids
}
