terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//state/s3?ref=tags/0.1.1"
}

include {
  path = find_in_parent_folders()
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

inputs = {
  attributes    = ["state"]
  force_destroy = true
}