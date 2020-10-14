variable "region" {
  default = "europe-west2"
}

variable "project_id" {
  description = "The project id in GCP"
}

variable "k8s_min_master_version" {
  description = "The minimum version of the master"
  default     = "1.16"
}

variable "k8s_machine_type" {
  description = "The machine type to provision"
  default     = "n1-standard-1"
}

variable "k8s_autoscaling_max_node_count" {
  description = "The maximum number of Kubernetes nodes (per region)"
  default     = 5
}
