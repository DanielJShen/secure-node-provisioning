#!/usr/bin/env bash
set -euxo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

KUSTOMIZATION_FILE="${SCRIPT_DIR}/build/kustomize/kustomization.yaml"
KUSTOMIZED_MANIFEST_FILE="${SCRIPT_DIR}/build/kustomize/argocd-install-namespaced.yaml"
SECRETS_FILE="${SCRIPT_DIR}/build/kustomize/secrets.yaml"
INITIAL_ARGO_APPS_FILE="${SCRIPT_DIR}/argocd-manifests.yaml"
OUTPUT_MANIFEST_FILE="${SCRIPT_DIR}/build/kustomize/argocd-manifest-final.yaml"

# Create the kustomize dir if it doesn't exist
mkdir -p "$(dirname "${KUSTOMIZATION_FILE}")"

# Create an ssh keypair and add the private key as a secret
read -p "Add a repository to ArgoCD? Optional, requires an ssh git repository url. <y/n> " prompt1
if [[ "${prompt1}" =~ [yY](es)* ]]; then
  read -p "SSH Git Repository URL: " repo_url
  rm "${SCRIPT_DIR}/build/kustomize/key" "${SCRIPT_DIR}/build/kustomize/key.pub"
  ssh-keygen -f "${SCRIPT_DIR}/build/kustomize/key"  -P "" -q
  BLUE='\033[0;36m'
  NC='\033[0m'
  echo -e "${BLUE}###\nAdd this SSH Key to your git repository:\n$(cat "${SCRIPT_DIR}/build/kustomize/key.pub")\n###${NC}"

  cat <<EOF | sed -e 's/^/  /' > "${SECRETS_FILE}"
apiVersion: v1
kind: Secret
metadata:
  name: private-argo-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${repo_url}
  sshPrivateKey: |-
$(cat "${SCRIPT_DIR}/build/kustomize/key" | sed -e 's/^/    /')
EOF
fi

# Use Kustomize to set the namespace throughout the manifest/s
INITIAL_ARGO_APPS_LOCAL_FILE="${SCRIPT_DIR}/build/kustomize/initial-argo-apps.yaml"
cp "${INITIAL_ARGO_APPS_FILE}" "${INITIAL_ARGO_APPS_LOCAL_FILE}"

cat <<EOF > "${KUSTOMIZATION_FILE}"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
  - https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  - ${INITIAL_ARGO_APPS_LOCAL_FILE}
EOF

kubectl kustomize "$(dirname "${KUSTOMIZATION_FILE}")" | sed -e 's/^/  /' > "${KUSTOMIZED_MANIFEST_FILE}"

# Prepend a namespace manifest
cat <<EOF | cat - "${KUSTOMIZED_MANIFEST_FILE}" <(echo "  ---") "${SECRETS_FILE}"  > "${OUTPUT_MANIFEST_FILE}"
apiVersion: v1alpha1
kind: KubeInlineManifestConfig
name: argocd-install
manifest: |-
  apiVersion: v1
  kind: Namespace
  metadata:
    name: argocd
  ---
EOF
