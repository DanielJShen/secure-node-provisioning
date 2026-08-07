#!/usr/bin/env bash
set -euxo pipefail
cd /opt

HOST="${1}"
SSH_PUBLIC_KEY="${2}"

if test -z "${HOST}" || test -z "${SSH_PUBLIC_KEY}"; then
  echo "Missing HOST and/or SSH_PUBLIC_KEY args"
  echo "example: <script> example.com keyString"
  exit 1
fi

# Run ansible
ansible-playbook -i "${HOST}" -u root -k \
  -e "sshPublicKey=${SSH_PUBLIC_KEY}" \
  playbook-root.yml