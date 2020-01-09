terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//state/local?ref=tags/0.1.0"
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