terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//aws/svc?ref=tags/0.1.1"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../dns",
    "../ecs",
    "../lb",
    "../vpc",
    "../webhook",
  ]
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  global = yamldecode(
    file(find_in_parent_folders("global_locals.yaml", local.default_yaml_path))
  )
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_name = "aws.epip.io"
    zone_id   = "mock_id"
  }
}

dependency "ecs" {
  config_path = "../ecs"

  mock_outputs = {
    ecs_name = "mock-name"
    ecs_arn  = "arn:mock::ecs:cluster"
  }
}

dependency "lb" {
  config_path = "../lb"

  mock_outputs = {
    security_group_id = "sg-alb-mock"
    alb_arn_suffix     = "app/mock/5246daa38a9ce1d2"
    listener_arns = [
      "arn:aws:elasticloadbalancing:::listener/app/mock/5246daa38a9ce1d2/64d812b25f833b1a",
      "arn:aws:elasticloadbalancing:::listener/app/mock/5246daa38a9ce1d2/bf883549a80dc99d",
    ]
    alb_zone_id  = "mock_id"
    alb_dns_name = "mock.io"
  }
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

dependency "webhook" {
  config_path = "../webhook"

  skip_outputs = true
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  ecs_name        = dependency.ecs.outputs.ecs_name
  ecs_cluster_arn = dependency.ecs.outputs.ecs_arn
  security_group_ids = [
    dependency.vpc.outputs.vpc_default_security_group_id
  ]

  container_image       = "parity/parity:v2.5.13-stable"
  container_port        = 8545
  container_cpu         = 512
  container_memory      = 256
  container_environment = []
  container_secrets     = []
  port_mappings = [
    {
      containerPort = 8545
      hostPort      = 8545
      protocol      = "tcp"
    }
  ]
  command = [
    "--jsonrpc-interface=all"
    "--jsonrpc-apis=safe",
    "--base-path",
    ".",
    "--chain",
    "kovan",
  ]

  alb_security_group            = dependency.lb.outputs.security_group_id
  alb_arn_suffix                = dependency.lb.outputs.alb_arn_suffix
  unauthenticated_listener_arns = dependency.lb.outputs.listener_arns
  unauthenticated_priority      = 102
  unauthenticated_hosts = [
    "parity.${dependency.dns.outputs.zone_name}"
  ]

  repo_owner   = local.global.github_organization
  repo_name    = element(local.global.github_repositories, 0)
  github_token = get_env("ATLANTIS_GH_TOKEN", "atlantis-gh-token")

  zone_id   = dependency.dns.outputs.zone_id
  zone_name = dependency.dns.outputs.zone_name

  alb_dns_name = dependency.lb.outputs.alb_dns_name
  alb_zone_id  = dependency.lb.outputs.alb_zone_id

  health_check_port = 4141

  attributes = []
}
