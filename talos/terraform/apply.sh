set -euxo pipefail

cd "$(dirname "$0")" || exit

docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 init

docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 apply -auto-approve

# Export kubeconfig
mkdir .kube
docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 output -raw kubeconfig > .kube/config

# Export talosconfig
mkdir .talos
docker run --rm -v "$(pwd):/opt/terraform" -w "/opt/terraform" hashicorp/terraform:1.15 output -raw talosconfig > .talos/config
