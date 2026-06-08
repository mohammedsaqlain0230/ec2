resource "aws_ec2_tag" "datadog_tag" {
  for_each = toset(var.instance_ids)

  resource_id = each.value

  key   = "Datadog"
  value = "Enabled"
}
