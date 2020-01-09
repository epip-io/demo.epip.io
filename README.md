# demo.epip.io

## Introduction

This repo is a is demostration of using Terragrunt to bring up a complete AWS minimal infrastructure. Where possible it makes uses of [free AWS](https://aws.amazon.com/free) services.

### Objectives

1. Bootstrap an full environment with a minimal number of commands. In this case, it is possible to full bootstrap the environment using 2 commands
2. Use Github Pull Requests, for continued lifecycle of the infrastructure with exception of teardown.

### Current Architecture

The current architecture uses [AWS](https://aws.amazon.com) as the infrastructure provider. It makes use of [AWS ECS](https://aws.amazon.com/ecs/) to orchestrator containers running on [EC2 instances](https://aws.amazon.com/ec2/).

To manage the [Terragrunt](https://terragrunt.gruntwork.io) code in this repository, it makes uses of a [custom container](https://hub.docker.com/r/stackstate/atlantis-terragrunt) running [Atlantis](https://www.runatlantis.io/) that includes the Terragrunt binary. It adds a webhook to this repo to allow for an Altantis pipepline to occur from this repo.

## Bootstrap

As mentioned in the [objectives](#objectives), bootstrapping is in two parts. This is for the purposes of the demo as the S3 bucket and DynamoDB table that Terragrunt creates are designed for production environments and thus have additional setting unnecessary for a proof of concept or demo.

To bootstrap, both [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) (v0.12.18 at time of writing) and [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (v0.21.10) needs to be installed. If necessary, make sure `AWS_PROFILE` is set to the right profile for the account that should be used.

### Bootstrap State Store

The first step is to bootstrap the storage used by Terraform to store its state. Using this makes it easier to destroy the full infrastructure when the demo is not needed. For those who know Terraform, the following commands will look familiar, this is due to Terragrunt being a wrapper to Terraform:

```bash
cd <path_to_repo_src>/bootstrap
terragrunt validate-all
terragrunt plan-all --terragrunt-include-dir atlantis --terragrunt-include-dir parity
terragrunt apply-all --terragrunt-include-dir atlantis --terragrunt-include-dir parity
```

If you have the [Terraform Demo Module repo](https://github.com/epip-io/terraform-demo-modules.git) cloned you can add `--terragrunt-source <path_to_module_repo>` to the above terragrunt commands

### Bootrstrap Infrastructure

Before bootstrapping the rest of the infrastructure a couple of environment variables need to be set. These are the same environment variables that are used by Atlantis to manage the lifecycle going forward:

```bash
export ATLANTIS_GH_USER=<Github User associated with Github Personal Token>
export ATLANTIS_GH_TOKEN=<Github Peronsal Token>
```

i.e:

```bash
export ATLANTIS_GH_USER=stormmore
export ATLANTIS_GH_TOKEN=d3df473666e7636a2d967f0ab7e39bfbd340dabe # This one no longer exists!
```

The token is actually stored using [AWS System Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) which can make use of [AWS KMS](https://aws.amazon.com/kms) to encrypt it at rest.

The commands to bootstrap the actual infrastructure are basically the same but in the `deploy` dir:

```bash
cd <path_to_repo_src>/deploy
terragrunt validate-all
terragrunt plan-all --terragrunt-exclude-dir atlantis --terragrunt-exclude-dir parity
terragrunt apply-all --terragrunt-exclude-dir atlantis --terragrunt-exclude-dir parity
```

If you [bootstrapped the state store](#bootstrap-state-store), then as part of the first `terragrunt` command executed, it will ask if the local state should be imported. It is recommended to do this, this will allow the enitre demostration to be cleaned up in one command.

## Deploy Services

Due to using data sources in the service Terraform module, it is necessary to bootstrap the infrastructure first and then do the initial deployment of the services. This is as simple as running:

```bash
cd <path_to_repo_src>/deploy
terragrunt plan-all --terragrunt-include-dir atlantis --terragrunt-include-dir parity
terragrunt apply-all --terragrunt-include-dir atlantis --terragrunt-include-dir parity
```

## To-Do List

- [x] AWS
  - [x] VPC
  - [x] Route 53
  - [x] ECS Cluster
  - [x] Atlantis Task & Service
  - [x] Parity Task & Service
- [x] Github
  - [x] Webhooks
    - [x] Atlantis
- [x] Atlantis pipeline
