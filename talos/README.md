# Talos

Installs Talos OS onto a bare-metal machine and manages it with Terraform

### Usage

#### Prerequisits

- Docker
- jq for talosctl provisioning
- A usb to install a Talos iso to

#### OS Install
Follow the below steps or use any of the other installation options on https://factory.talos.dev

1. Download the image from https://factory.talos.dev
   1. Must match the talosctl version or talos version in variables.tf
   2. Some storage provisioners require extensions siderolabs/iscsi-tools and siderolabs/util-linux-tools
   3. Example: https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=3a33ec6dfc8cfd61d2a3db3caf97894f31e913952d71ce3c3fbbe565a3f08339&secureboot=true&target=metal&$
2. Make a bootable usb from the iso
   1. Unmount the USB if mounted
   2. Apply the iso to the usb:
   ```shell
   sudo cp <downloadedIsoName>.iso /dev/disk/by-id/<usb-id>
   sudo sync
   ```
3. Boot the target machine from the usb
   1. Select the first entry if Talos is not already installed
   2. Select the second entry to reset the installed Talos and then after it has reset select the first entry
4. Press F3 on the machine and configure the network settings
   You may need to set a static IP and disable EEE in the router settings

#### Provision

1. Create a private git repo
2. Follow the steps in either 'With Terraform' or 'With talosctl'
3. Add the provided SSH key to the repo
4. Add kustomize.yaml files to the repo under folder structure `<namespace>/<app_name>/` to have ArgoCD apply them

##### With Terraform

1. Update `terraform/terraform.tfvars` with the machines IP (displayed on the machine if the network setup was successful)
2. Run `terraform/plan.sh` to view the terraform plan
3. Run `terraform/apply.sh` to setup the machine

##### With talosctl

1. Run `talosctl/provision.sh <MACHINE_IP>` and follow prompts (MACHINE_IP displayed on the machine if the network setup was successful)
  1. If providing a git repository, you can add applications by having directory structure `<namespace>/<appName>/kustomize.yaml` in the provided repo
2. Visit ArgoCD
  1. Run `kubectl port-forward svc/argocd-server -n argocd 8080:443 --kubeconfig='talosctl/build/kubeconfig'`
  2. Visit `localhost:8080`
  3. Get the password with `kubectl get secret argocd-initial-admin-secret -n argocd --kubeconfig='talosctl/build/kubeconfig' -o json | jq -r '.data.password' | base64 -d`
  4. Login with username `admin` and the fetched password

###### Changing/Adding disks
1. Edit talosctl/machine-storage-patch.yaml with the new config
2. Run `talosctl patch machineconfig --patch @talosctl/machine-storage-patch.yaml --talosconfig=talosctl/build/talosconfig --nodes <NODE_IP>`
