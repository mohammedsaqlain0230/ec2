resource "aws_ssm_association" "datadog" {

  name = aws_ssm_document.datadog_install.name

  targets {
    key    = "tag:Datadog"
    values = ["Enabled"]
  }
}
