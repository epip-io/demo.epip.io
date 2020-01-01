terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//aws/r53/zone?ref=tags/v0.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../state",
  ]
}