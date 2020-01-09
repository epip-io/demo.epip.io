terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//aws/acm?ref=tags/0.1.1"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../dns",
  ]
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    # This zone has to exist, it is the "parent" zone for the environment
    zone_name = "aws.epip.io"
  }
}

inputs = {
  domain_name = dependency.dns.outputs.zone_name

  attributes = []
}
