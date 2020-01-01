terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//aws/acm?ref=tags/v0.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../r53"
  ]
}

dependency "r53" {
  config_path = "../r53"

  mock_outputs = {
    domain_name = "demo.io"

    zone_id = "ZMOCK1234567890"
  }
}

inputs = {
  zone_id = dependency.r53.outputs.zone_id
}