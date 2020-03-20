variable "region" {
  default = "europe-west2"
}

variable "gcp_billing_account" {
  description = "The billing account the project will use, defaults to the Census CTS account"
}

variable "gcp_folder_id" {
  description = "The numeric ID of the folder this project belongs to"
}

variable "project_id" {
  description = "The project id in GCP"
}

variable "k8s_min_master_version" {
  description = "The minimum version of the master"
  default     = "1.14"
}

variable "machine_type" {
  description = "The machine type to provision"
  default     = "n1-standard-1"
}
