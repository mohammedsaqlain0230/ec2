resource "aws_ssm_document" "datadog_install" {

  name          = "Datadog-Install"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"

    description = "Install Datadog Agent"

    mainSteps = [
      {
        action = "aws:runShellScript"

        name = "installDatadog"

        inputs = {
          runCommand = split("\n", file("${path.module}/scripts/datadog-install.sh"))
        }
      }
    ]
  })
}
