# Debian
Installs a slim Debian OS and the bare essentials for container management.

### Components

- installation - A tool to create an auto-installing bootable iso file
- provisioning - An ansible script to do the following:
    - Harden the Linux OS
    - Make the OS files boot as read-only
    - Install a container management tool or an agent for one
    - Set up the network and SSH access

### Usage

1. Install docker
2. Install Debian to hardware (Optional)
    1. Build the installation iso
        1. Open a terminal at the debian dir `cd ./debian`
        2. Build the docker image `docker build --tag 'installer-iso-builder' ./installation`
        3. Run it with `docker run --rm installer-iso-builder -v "$(PWD)/installation/build:/opt/build"`
    3. Create a bootable usb from iso
        3. The following commands can be used:
           `sudo dd if=<input_file> of=<device_name>`
           `sync`
           or `cp debian.iso /dev/sdx`?

           **The device provided will be overwritten, use with care**
    4. Install the given Linux OS onto the hardware by booting from the usb

       **Only empty disk space should be used, but proceed with caution**
3. Provision the Linux OS
    1. Build the docker image `docker build --tag 'node-provisioner' ./installation`
    2. Run it with `docker run --rm node-provisioner`
    3. Follow the prompts to provision