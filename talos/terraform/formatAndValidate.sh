#!/usr/bin/env bash
set -euxo pipefail

cd "$(dirname "$0")" || exit

docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 fmt

docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 validate
