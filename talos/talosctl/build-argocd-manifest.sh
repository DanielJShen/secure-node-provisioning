#!/usr/bin/env bash
set -euxo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

ARGO_BASE_MANIFEST_FILENAME="argocd-install.yaml"
ARGO_BASE_MANIFEST_FILE="${SCRIPT_DIR}/build/kustomize/${ARGO_BASE_MANIFEST_FILENAME}"
KUSTOMIZATION_FILE="${SCRIPT_DIR}/build/kustomize/kustomization.yaml"
KUSTOMIZED_MANIFEST_FILE="${SCRIPT_DIR}/build/kustomize/argocd-install-namespaced.yaml"
OUTPUT_MANIFEST_FILE="${SCRIPT_DIR}/build/kustomize/argocd-manifest-final.yaml"

# Fetch ArgoCD Manifest
mkdir -p "$(dirname "${ARGO_BASE_MANIFEST_FILE}")"
curl -Lo "${ARGO_BASE_MANIFEST_FILE}" \
  "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

# Use Kustomize to set the namespace throughout the manifest
cat <<EOF > "${KUSTOMIZATION_FILE}"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
  - ${ARGO_BASE_MANIFEST_FILENAME}
EOF

kubectl kustomize "$(dirname "${KUSTOMIZATION_FILE}")" | sed -e 's/^/  /' > "${KUSTOMIZED_MANIFEST_FILE}"

# Prepend a namespace manifest
cat <<EOF | cat - "${KUSTOMIZED_MANIFEST_FILE}" > "${OUTPUT_MANIFEST_FILE}"
apiVersion: v1alpha1
kind: KubeInlineManifestConfig
name: argocd_install
manifest: |-
  apiVersion: v1
  kind: Namespace
  metadata:
    name: argocd
  ---
EOF
