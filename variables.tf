variable "aws_region" {
  default = "ap-south-1"
}

variable "datadog_api_key" {
  sensitive = true
}

variable "datadog_site" {
  default = "datadoghq.com"
}
