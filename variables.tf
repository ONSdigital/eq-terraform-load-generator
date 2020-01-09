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
  description = "The project name in GCP"
}

variable "project_env" {
  description = "The environment this project belongs to, for billing and reporting purposes, etc"
  default     = "sandbox-eq"
}

variable "project_team" {
  description = "The team this project belongs to, for billing and reporting purposes, etc"
  default     = "eq"
}

variable "k8s_min_master_version" {
  description = "The minimum version of the master"
  default     = "1.13"
}
