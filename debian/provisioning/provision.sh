#!/usr/bin/env bash
set -euxo pipefail
cd /opt

HOST="${1}"
SSH_PUBLIC_KEY="${2}"
SSH_INITIAL_PASSWORD="${3}"

if test -z "${HOST}" \
  || test -z "${SSH_PUBLIC_KEY}" \
  || test -z "${SSH_INITIAL_PASSWORD}"; then
  echo "Missing HOST, SSH_PUBLIC_KEY or SSH_INITIAL_PASSWORD args"
  echo "example: <script> example.com keyString initialSshPass"
  exit 1
fi

# Run ansible
ansible-playbook -i "${HOST}" -u root -k \
  -e "sshPublicKey=${SSH_PUBLIC_KEY}" \
  -e "ansible_password=${SSH_INITIAL_PASSWORD}" \
  playbook-root.yml