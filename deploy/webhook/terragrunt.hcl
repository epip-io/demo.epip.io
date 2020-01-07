terraform {
  source = "git::https://github.com/epip-io/terraform-demo-modules.git//gh/webhook?ref=tags/0.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../dns",
  ]
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_name = "aws.epip.io"
  }
}

inputs = {
  name = "ATLANTIS_GH_WEBHOOK_SECRET"

  github_token        = get_env("ATLANTIS_GH_TOKEN", "atlantis-gh-token")
  github_organization = local.global.github_organization
  github_repositories = local.global.github_repositories
  webhook_url         = "https://atlantis.${dependency.dns.outputs.zone_name}"

  events = [
    "issue_comment",
    "pull_request",
    "pull_request_review",
    "pull_request_review_comment",
    "push",
  ]

  attributes = []
}