#!/usr/bin/env bash

getConfigOrPrompt () {
  echo
  # Check if field is already configured, if not prompt the user for the value
}

# Prompt for host to provision
getConfigOrPrompt x y z

# Prompt for other details
getConfigOrPrompt x y z

# Run ansible
ansible-playbook -i example.net, -u ansible -k -e ansible_network_os=123 playbook-root.yml