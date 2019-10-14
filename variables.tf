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

variable "k8s_subnetwork_nodes_cidr" {
  description = "The Kubernetes nodes subnetwork CIDR"
  default     = "10.60.0.0/16"
}

variable "k8s_subnetwork_pods_alias_cidr" {
  description = "The Kubernetes pods subnetwork alias CIDR"
  default     = "10.70.0.0/16"
}

variable "k8s_subnetwork_services_alias_cidr" {
  description = "The Kubernetes services subnetwork alias CIDR"
  default     = "10.80.0.0/16"
}

variable "k8s_master_cidr" {
  description = "The Kubernetes master CIDR"
  default     = "10.90.0.0/28"
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

variable "additional_k8s_master_whitelist_cidrs" {
  type = "list"

  default = []
}

variable "runner_url" {
  description = "The runner url to benchmark tests against e.g. myenv-runner.gcp.dev.eq.ons.digital"
}

variable "locust_fully_qualified_domain_name" {
  description = "Fully Qualified Domain Name for locust e.g. myenv-locust.gcp.dev.eq.ons.digital"
}

variable "create_dns" {
  description = "If set to true DNS records will be created in the specified dns project"
  default     = false
}

variable "create_locust_ssl_cert" {
  description = "If set to true an SSL runner certificate will be created"
  default     = false
}

variable "dns_project" {
  description = "The name of the project that contains the DNS zone"
  default     = "dns-census-eq-global"
}

variable "dns_zone_name" {
  description = "The DNS zone name within the DNS project"
  default     = "eq"
}