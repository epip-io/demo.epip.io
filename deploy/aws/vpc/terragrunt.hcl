terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//aws/vpc?ref=tags/v0.1.0"
}

include {
    path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../state",
  ]
}
inputs = {
    cidr = "10.0.0.0/22"

    tenancy = "default"
}