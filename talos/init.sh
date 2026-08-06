cd "$(dirname "$0")" || exit

# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Create the cluster
terraform apply

# Export kubeconfig
terraform output -raw kubeconfig > .kube/config
chmod 600 .kube/config

# Export talosconfig
terraform output -raw talosconfig > .talos/config
chmod 600 .talos/config

# Verify
kubectl get nodes
talosctl health --nodes 10.0.0.10