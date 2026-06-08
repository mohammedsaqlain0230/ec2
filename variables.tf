variable "aws_region" {
  default = "ap-south-1"
}

variable "datadog_api_key" {
  sensitive = true
}

variable "datadog_site" {
  default = "datadoghq.com"
}
variable "instance_ids" {
  description = "List of EC2 instance IDs to tag with Datadog=Enabled"
  type        = list(string)
}
