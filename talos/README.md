# Talos

Installs Talos OS onto a bare-metal machine and manages it with Terraform

### Usage

#### OS Install
Follow the below steps or use any of the other installation options on https://factory.talos.dev

1. Download the image from https://factory.talos.dev
   1. Example: https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=9c1d1b442d73f96dcd04e81463eb20000ab014062d22e1b083e1773336bc1dd5&secureboot=true&target=metal&$
2. Make a bootable usb from the iso
   1. Unmount the USB if mounted
   2. Apply the iso to the usb:
   ```shell
   sudo cp <downloadedIsoName>.iso /dev/disk/by-id/<usb-id>
   sudo sync
   ```
3. Boot the target machine from the usb and select the first entry to run Talos
4. Press F3 on the machine and configure the network settings
   You may need to set a static IP and disable EEE in the router settings

#### Provision with Terraform

1. Run the terraform apply script with the machines IP (displayed on the machine if the network setup was successful)
2.
