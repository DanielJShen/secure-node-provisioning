#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

CONTROL_PLANE_IP="${1}"
CLUSTER_NAME="${2:-main}"
TALOSCTL_IMAGE="${3:-v1.14.0-rc.1}"

function docker_talosctl {
  docker run --rm -v "$(pwd):/opt/" -w "/opt/"  "ghcr.io/siderolabs/talosctl:${TALOSCTL_IMAGE}" $@
}

TALOS_CONFIG_FILE="${SCRIPT_DIR}/build/talosconfig"
DOCKER_WORKING_DIR="/opt"
TALOS_CONFIG_FILE_DOCKER="${DOCKER_WORKING_DIR}/build/talosconfig"

read -p "Generate new config? Must be done at least once. <Y/n> " prompt1
if [[ "${prompt1}" =~ [yY](es)* ]]; then
  "${SCRIPT_DIR}/build-machine-config.sh" "${CONTROL_PLANE_IP}" "${CLUSTER_NAME}" "${TALOSCTL_IMAGE}"
fi

read -p "Apply config? Installs on the disk. <Y/n> " prompt2
if [[ "${prompt2}" =~ [yY](es)* ]]; then

  docker_talosctl apply-config --insecure --nodes "${CONTROL_PLANE_IP}" --file "${DOCKER_WORKING_DIR}/build/controlplane.yaml"

  docker_talosctl --talosconfig="${TALOS_CONFIG_FILE_DOCKER}" config endpoints "${CONTROL_PLANE_IP}"
fi

read -p "Run Bootstrap? Must only be done once and only after the config is applied and the machine rebooted. <Y/n> " prompt3
if [[ "${prompt3}" =~ [yY](es)* ]]; then

  docker_talosctl bootstrap --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE_DOCKER}"
fi

docker_talosctl kubeconfig "${DOCKER_WORKING_DIR}/build/kubeconfig" --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE_DOCKER}"

docker_talosctl --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE_DOCKER}" health
