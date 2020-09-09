variable "name" {
  description = "The name of the REST API"
  type = string
}

variable "stage_name" {
  description = "The stage name for the API deployment (production/staging/etc..)"
  type = string
}

variable "method" {
  description = "The HTTP method"
  default = "GET"
  type = string
}

variable "lambda" {
  description = "The lambda name to invoke"
  type = string
}

variable "lambda_arn" {
  description = "The lambda arn to invoke"
  type = string
}

variable "custom_domain" {
  type = string
}

variable "custom_domain_certificate_arn" {
  type = string
}