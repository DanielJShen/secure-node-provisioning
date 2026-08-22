#!/usr/bin/env bash
set -euxo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

CONTROL_PLANE_IP="${1}"
CLUSTER_NAME="${2:-main}"

TALOS_CONFIG_FILE="${SCRIPT_DIR}/../.talos/config"

read -p "Generate new config? Must be done at least once. <Y/n> " prompt1
if [[ "${prompt1}" =~ [yY](es)* ]]; then

  INSTALL_DISK="$(talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr '.[] | select(.spec.readonly == false) | .spec.dev_path' | head -n1)"
  INSTALL_DISK_NAME="$(talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr ".[] | select(.spec.dev_path == \"${INSTALL_DISK}\") | .spec.model" | head -n1)"

  "${SCRIPT_DIR}/build-argocd-manifest.sh"

  talosctl gen config "${CLUSTER_NAME}" "https://${CONTROL_PLANE_IP}:6443" --install-disk "${INSTALL_DISK}" \
    --output "${SCRIPT_DIR}/build/"  --output-types "controlplane" --output-types "talosconfig" --force \
    --with-docs --config-patch "${SCRIPT_DIR}/machine-patch.yaml" --config-patch-control-plane "${SCRIPT_DIR}/build/kustomize/argocd-manifest-final.yaml"

  echo "###"
  echo "Configured to install to disk '${INSTALL_DISK}' with name '${INSTALL_DISK_NAME}'"
  echo "###"
fi

read -p "Apply config? Installs on the disk. <Y/n> " prompt2
if [[ "${prompt2}" =~ [yY](es)* ]]; then

  cp "${SCRIPT_DIR}/build/talosconfig" "${TALOS_CONFIG_FILE}"

  talosctl apply-config --insecure --nodes "${CONTROL_PLANE_IP}" --file "${SCRIPT_DIR}/build/controlplane.yaml"

  talosctl --talosconfig="${TALOS_CONFIG_FILE}" config endpoints "${CONTROL_PLANE_IP}"
fi

read -p "Run Bootstrap? Must only be done once and only after config is applied. <Y/n> " prompt3
if [[ "${prompt3}" =~ [yY](es)* ]]; then

  talosctl bootstrap --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}"
fi

talosctl kubeconfig "${SCRIPT_DIR}/../.kube/config" --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}"

talosctl --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}" health
