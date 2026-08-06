terraform {
  required_version = ">= 1.15.0"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.2.1"
    }
  }
}

provider "talos" {}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}