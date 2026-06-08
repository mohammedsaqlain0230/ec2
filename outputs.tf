output "ssm_document" {
  value = aws_ssm_document.datadog_install.name
}

output "ssm_association_id" {
  value = aws_ssm_association.datadog.id
}
