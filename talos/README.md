# Talos

Installs Talos OS onto a bare-metal machine and manages it with Terraform

### Usage

#### OS Install
Follow the below steps or use any of the other installation options on https://factory.talos.dev

1. Download the image from https://factory.talos.dev
   2. Example: https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=9c1d1b442d73f96dcd04e81463eb20000ab014062d22e1b083e1773336bc1dd5&secureboot=true&target=metal&version=1.13.8
2. Make a bootable usb from the iso
   1. Run `cp .iso /dev/sda`
3. Boot the target machine from the usb
4. Follow install steps

#### Provision with Terraform

1. 