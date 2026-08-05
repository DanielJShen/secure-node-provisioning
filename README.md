# secure-node-provisioning

A set of tools to automatically provision hardware with a basic Linux install and the bare essentials for container management.

# Components

- Installation - A tool to create an auto-installing bootable iso file
- Provisioning - An ansible script to do the following:
  - Harden the Linux OS
  - Make the OS files boot as read-only
  - Install a container management tool or an agent for one
  - Setup the network and SSH access
