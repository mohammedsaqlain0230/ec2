resource "aws_ssm_parameter" "datadog_api_key" {
  name  = "/datadog/api-key"
  type  = "SecureString"
  value = var.datadog_api_key
}
