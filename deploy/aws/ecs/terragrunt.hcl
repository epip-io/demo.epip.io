terraform {
  source = "github.com/epip-io/terraform-demo-modules-git//aws/ecs/cluster?ref=tags/v0.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../vpc"
  ]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    default_security_group_id = "sg-mock"

    private_subnets = [
      "demo.io-private-1",
      "demo.io-private-2",
      "demo.io-private-3",
    ]
  }
}

inputs = {
  default_security_group_id = dependency.vpc.outputs.default_security_group_id
  private_subnets = dependency.vpc.outputs.private_subnets
}