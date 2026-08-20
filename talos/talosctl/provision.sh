#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")" || exit

CONTROL_PLANE_IP="${1}"
CLUSTER_NAME="${2:-main}"

INSTALL_DISK="$(talosctl get disks --insecure --nodes "${CONTROL_PLANE_IP}")"

#talosctl gen config "${CLUSTER_NAME}" "https://${CONTROL_PLANE_IP}:6443" --install-disk "/dev/${INSTALL_DISK}" > ../.talos/machine_config

#talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml

#talosctl --talosconfig=../.talos/talosconfig config endpoints "${CONTROL_PLANE_IP}"

#talosctl bootstrap --nodes "${CONTROL_PLANE_IP}" --talosconfig=../.talos/talosconfig

#talosctl kubeconfig ../.kube/config --nodes "${CONTROL_PLANE_IP}" --talosconfig=../.talos/talosconfig

#talosctl --nodes "${CONTROL_PLANE_IP}" --talosconfig=../.talos/talosconfig health
