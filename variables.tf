variable "region" {
  type    = string
  default = "europe-west2"
}

variable "project_id" {
  type        = string
  description = "The project id in GCP"
}

variable "k8s_machine_type" {
  type        = string
  description = "The machine type to provision"
  default     = "custom-2-2560"
}

variable "k8s_autoscaling_max_node_count" {
  type        = number
  description = "The maximum number of Kubernetes nodes (per region)"
  default     = 5
}

variable "k8s_master_authorized_networks" {
  type = map(string)
  description = "Map of authorized network CIDRs that can access the private Kubernetes API. Key is the name, value is the CIDR block."
  default = {} # TODO: Add authorized networks
}
