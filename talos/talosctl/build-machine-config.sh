#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

CONTROL_PLANE_IP="${1}"
CLUSTER_NAME="${2:-main}"
TALOSCTL_IMAGE="${3:-v1.14.0-rc.1}"

function docker_talosctl {
  docker run --rm -v "${SCRIPT_DIR}:/opt/" -w "/opt/"  "ghcr.io/siderolabs/talosctl:${TALOSCTL_IMAGE}" $@
}

TALOS_CONFIG_FILE="${SCRIPT_DIR}/build/talosconfig"

INSTALL_DISKS="$(docker_talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr '.[] | select(.spec.readonly == false) | .spec.dev_path')"
IFS=$'\n' INSTALL_DISKS_ARRAY=( ${INSTALL_DISKS} )

echo
echo "Disks:"
for (( i=0; i<${#INSTALL_DISKS_ARRAY[@]}; i++ )); do
  INSTALL_DISK_N="${INSTALL_DISKS_ARRAY[i]}"
  INSTALL_DISK_NAME_N="$(docker_talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr ".[] | select(.spec.dev_path == \"${INSTALL_DISK_N}\") | .spec.model" | head -n1)"
  echo "  [$i] ${INSTALL_DISK_N} - ${INSTALL_DISK_NAME_N}"
done
read -p "Please select the install disk: " install_disk_choice
INSTALL_DISK="${INSTALL_DISKS_ARRAY[install_disk_choice]}"

if [ -z "${INSTALL_DISK}" ]; then
  echo "Disk not found!"
  exit 1
fi
INSTALL_DISK_NAME="$(docker_talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}" -o json 2>/dev/null | jq -sr ".[] | select(.spec.dev_path == \"${INSTALL_DISK}\") | .spec.model" | head -n1)"

echo
"${SCRIPT_DIR}/build-argocd-manifest.sh"

docker_talosctl gen config "${CLUSTER_NAME}" "https://${CONTROL_PLANE_IP}:6443" --install-disk "${INSTALL_DISK}" \
  --output "/opt/build/"  --output-types "controlplane" --output-types "talosconfig" --force \
  --with-docs --config-patch "/opt/machine-patch.yaml" --config-patch-control-plane "/opt/build/kustomize/argocd-manifest-final.yaml" --config-patch "/opt/machine-storage-patch.yaml" 2>/dev/null

BLUE='\033[0;36m'
NC='\033[0m'
echo
echo -e "${BLUE}###"
echo    "Configured to install to disk '${INSTALL_DISK}' with name '${INSTALL_DISK_NAME}'"
echo    "Output files:"
echo    "  ${SCRIPT_DIR}/build/controlplane.yaml"
echo    "  ${SCRIPT_DIR}/build/talosconfig"
echo -e "###${NC}"
