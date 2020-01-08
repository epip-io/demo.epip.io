terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules-git//aws/ecs?ref=tags/v0.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../vpc",
    "../lb",
  ]
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock"

    private_subnet_ids = [
      "subent-private-1",
      "subent-private-2",
      "subent-private-3",
    ]

    vpc_default_security_group_id = "sg-vpc-mock"
  }
}

dependency "lb" {
  config_path = "../lb"

  mock_outputs = {
    security_group_id = "sg-alb-mock"

    default_target_group_arn = "arn::mock::target:group"

    alb_arn = "arn::mock::alb:arn"
  }
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  load_balancers = [
    dependency.lb.outputs.alb_arn
  ]

  target_group_arns = [
    dependency.lb.outputs.default_target_group_arn
  ]

  security_group_ids = [
    dependency.lb.outputs.security_group_id,
    dependency.vpc.outputs.vpc_default_security_group_id,
  ]

  min_size = 1
  max_size = 3

  ebs_optimized = true

  attributes = []
}