terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//aws/vpc?ref=tags/0.1.1"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../state",
  ]
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

inputs = {
  attributes = ["vpc"]
  cidr_block = "10.0.0.0/16"

  attributes = []
}