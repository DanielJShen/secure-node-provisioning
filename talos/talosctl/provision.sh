#!/usr/bin/env bash
set -euxo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

CONTROL_PLANE_IP="${1}"
CLUSTER_NAME="${2:-main}"

INSTALL_DISK="$(talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr '.[] | select(.spec.readonly == false) | .spec.dev_path' | head -n1)"
INSTALL_DISK_NAME="$(talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr ".[] | select(.spec.dev_path == \"${INSTALL_DISK}\") | .spec.model" | head -n1)"

"${SCRIPT_DIR}/build-argocd-manifest.sh"

talosctl gen config "${CLUSTER_NAME}" "https://${CONTROL_PLANE_IP}:6443" --install-disk "${INSTALL_DISK}" \
 --output "${SCRIPT_DIR}/build/"  --output-types "controlplane" --output-types "talosconfig" --force \
 --with-docs --config-patch-control-plane "${SCRIPT_DIR}/config-patch.yaml" --config-patch "${SCRIPT_DIR}/hostname-patch.yaml" --config-patch-control-plane "${SCRIPT_DIR}/build/kustomize/argocd-manifest-final.yaml"

read -p "Install to disk '${INSTALL_DISK}' with name '${INSTALL_DISK_NAME}'? <y/N> " prompt
if [[ ! "${prompt}" =~ [yY](es)* ]]; then
  exit 0
fi

TALOS_CONFIG_FILE="${SCRIPT_DIR}/../.talos/config"
cp "${SCRIPT_DIR}/build/talosconfig" "${TALOS_CONFIG_FILE}"

talosctl apply-config --insecure --nodes "${CONTROL_PLANE_IP}" --file "${SCRIPT_DIR}/build/controlplane.yaml"

talosctl --talosconfig="${TALOS_CONFIG_FILE}" config endpoints "${CONTROL_PLANE_IP}"

talosctl bootstrap --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}"

talosctl kubeconfig "${SCRIPT_DIR}/../.kube/config" --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}"

talosctl --nodes "${CONTROL_PLANE_IP}" --talosconfig="${TALOS_CONFIG_FILE}" health
