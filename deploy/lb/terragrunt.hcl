terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//aws/alb?ref=tags/0.1.1"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  // "../cert",
  paths = [
    "../vpc",
  ]
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

// dependency "cert" {
//   config_path = "../cert"

//   mock_outputs = {
//     arn = "arn:mock::cert/mock"
//   }
// }

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id     = "vpc-mock"
    vpc_region = "us-east-1"
    public_subnet_ids = [
      "subnet-1",
      "subnet-2",
      "subnet-3",
    ]
  }
}

inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  subnet_ids        = dependency.vpc.outputs.public_subnet_ids
  ip_address_type   = "ipv4"
  access_log_region = dependency.vpc.outputs.vpc_region

  https_enabled             = false
  http_ingress_cidr_blocks  = ["0.0.0.0/0"]
  https_ingress_cidr_blocks = ["0.0.0.0/0"]
  // certificate_arn           = dependency.cert.outputs.arn

  attributes = []
}