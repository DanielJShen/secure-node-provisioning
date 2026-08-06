#!/usr/bin/env bash
set -euxo pipefail

cd "$(dirname "$0")" || exit

terraform_command="fmt"
docker run -it --rm -v "$(PWD)/terraform:/opt/terraform" hashicorp/terraform:1.15 "${terraform_command}"

terraform_command="validate"
docker run -it --rm -v "$(PWD)/terraform:/opt/terraform" hashicorp/terraform:1.15 "${terraform_command}"
