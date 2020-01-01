terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//aws/state/remote?ref=tags/v0.1.0"
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
  bucket = local.global.state_bucket
}
