variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "main"
}

variable "talos_version" {
  description = "Talos Linux version"
  type        = string
  default     = "v1.13.8"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.36.2"
}

variable "controlplane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 0
}

variable "controlplane_ips" {
  description = "IP addresses for control plane nodes"
  type        = list(string)
  default     = ["10.0.0.10"]
}

variable "worker_ips" {
  description = "IP addresses for worker nodes"
  type        = list(string)
  default     = []
}

variable "cluster_vip" {
  description = "Virtual IP for the cluster endpoint"
  type        = string
  default     = "10.0.0.10"
}

variable "schematic_id" {
  description = "Image Factory schematic ID"
  type        = string
  default     = "d10dca86e929d1fdb42de191589d8d79ebff348b522307f0f08207e693348c02"
}
