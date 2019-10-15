variable "region" {
  default = "europe-west2"
}

variable "gcp_billing_account" {
  description = "The billing account the project will use, defaults to the Census CTS account"
}

variable "gcp_folder_id" {
  description = "The numeric ID of the folder this project belongs to"
}

variable "env" {
  description = "Environment name - used as the project name in GCP"
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

variable "k8s_master_whitelist_cidrs" {
  type = "list"

  default = [
    {
      display_name = "EQ CI NAT"
      cidr_block   = "35.197.219.46/32"
    },
    {
      display_name = "Central CI NAT"
      cidr_block   = "35.242.166.25/32"
    }
  ]
}

variable "runner_url" {
  description = "The runner url to benchmark tests against e.g. myenv-runner.gcp.dev.eq.ons.digital"
}