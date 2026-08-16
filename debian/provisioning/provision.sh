#!/usr/bin/env bash
set -euxo pipefail
cd /opt

if test -z "${1}" \
  || test -z "${2}" \
  || test -z "${3}"; then
  echo "Missing HOST, SSH_PUBLIC_KEY or SSH_INITIAL_PASSWORD args"
  echo "example: <script> example.com keyString initialSshPass"
  exit 1
fi

HOST="${1}"
SSH_PUBLIC_KEY="${2}"
SSH_INITIAL_PASSWORD="${3}"

echo "${HOST}" > /opt/hosts
echo > /opt/build/output/playbook.log

# Run ansible
ansible-playbook -i "/opt/hosts" -u provisioner -k \
  -e "sshPublicKey='${SSH_PUBLIC_KEY}'" \
  -e "ansible_password='${SSH_INITIAL_PASSWORD}'" \
  -e "ansible_sudo_pass='${SSH_INITIAL_PASSWORD}'" \
  playbook-root.yml || {

  set +x
  echo
  echo "########## Extracted Module Stderr:"
  echo -e  $(cat /opt/build/output/playbook.log | grep "module_stderr") | ascii2uni -a U -q

}
