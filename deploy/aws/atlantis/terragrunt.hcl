terraform {
  source = "github.com/epip-io/terraform-demo-modules.git//aws/ecs/task/atlantis?ref=tags/v0.1.0"
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

dependencies {
  paths = [
    "../r53",
    "../vpc",
    "../acm",
    "../ecs",
  ]
}

dependency "r53" {
  config_path = "../r53"

  mock_outputs = {
    domain_name = "demo.io"

    zone_id = "ZMOCK1234567890"
  }
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

    public_subnets = [
      "demo.io-public-1",
      "demo.io-public-2",
      "demo.io-public-3",
    ]

    vpc_id = "vpc-mock"
  }
}

dependency "ecs" {
  config_path = "../ecs"

  mock_outputs = {
    this_ecs_cluster_id = "demo.io"
  }
}

dependency "acm" {
  config_path = "../acm"

  mock_outputs = {
    this_acm_certificate_arn = "arn:aws:acm::mock"
  }
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  public_subnet_ids  = dependency.vpc.outputs.public_subnets

  zone_id = dependency.r53.outputs.zone_id

  certificate_arn = dependency.acm.outputs.this_acm_certificate_arn

  atlantis_image          = "stackstate/atlantis-terragrunt:latest"
  atlantis_repo_whitelist = [
    format("github.com/%s/%s", local.global.repo_org, local.global.repo_name),
  ]
  atlantis_github_user         = get_env("ATLANTIS_GH_USER", "")
  atlantis_github_organization = local.global.repo_org
  atlantis_github_repo = local.global.repo_name
  atlantis_github_token        = get_env("ATLANTIS_GH_TOKEN", "")

  ecs_cluster_id = dependency.ecs.outputs.this_ecs_cluster_id
}