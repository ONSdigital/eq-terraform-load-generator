terraform {
  backend "gcs" {
    bucket = "census-eq-terraform-tfstate"
  }
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "benchmark-${var.env}-"
}

provider "google" {
  region = "${var.region}"
}

provider "google-beta" {}

output "region" {
  value = "${var.region}"
}

resource "google_project" "project" {
  name            = "${var.env}"
  project_id      = "${random_id.id.hex}"
  folder_id       = "${var.gcp_folder_id}"
  billing_account = "${var.gcp_billing_account}"

  labels {
    terraform = "census-eq-terraform"
    team      = "${var.project_team}"
    env       = "${var.project_env}"
  }

  lifecycle {
    ignore_changes = ["project_id", "name"]
  }
}

output "google_project_id" {
  value = "${google_project.project.project_id}"
}

// This enables app engine, but more importantly also enables Datastore
resource "google_app_engine_application" "app" {
  project     = "${google_project.project.project_id}"
  location_id = "${var.region}"
}

resource "google_project_service" "compute" {
  project = "${google_project.project.project_id}"
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "container" {
  project = "${google_project.project.project_id}"
  service = "container.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "logging" {
  project = "${google_project.project.project_id}"
  service = "logging.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

// SUBNET & SECONDARIES
resource "google_compute_network" "k8s" {
  depends_on              = ["google_project_service.compute"]
  name                    = "k8s"
  auto_create_subnetworks = "false"
  project                 = "${google_project.project.project_id}"
}

resource "google_compute_subnetwork" "nodes" {
  name                     = "nodes"
  ip_cidr_range            = "${var.k8s_subnetwork_nodes_cidr}"
  network                  = "${google_compute_network.k8s.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = "1"
  project                  = "${google_compute_network.k8s.project}"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "${var.k8s_subnetwork_pods_alias_cidr}"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "${var.k8s_subnetwork_services_alias_cidr}"
  }
}

resource "google_compute_router" "eq-router" {
  name    = "eq-router"
  region  = "${google_compute_subnetwork.nodes.region}"
  network = "${google_compute_subnetwork.nodes.network}"
  project = "${google_compute_subnetwork.nodes.project}"
}

resource "google_compute_router_nat" "eq-nat" {
  name                               = "eq-nat"
  router                             = "${google_compute_router.eq-router.name}"
  project                            = "${google_compute_router.eq-router.project}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

// GKE

# service account for compute engine instances
resource "google_service_account" "compute" {
  account_id   = "compute"
  display_name = "Compute Engine service account"
  project      = "${google_project.project.project_id}"
}

resource "google_project_iam_member" "compute" {
  project = "${google_project.project.project_id}"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.compute.email}"
}

resource "google_container_cluster" "runner-benchmark" {
  name                     = "runner-benchmark"
  description              = "Private Kubernetes Cluster - Dev Benchmark environment"
  location                 = "${var.region}"
  min_master_version       = "${var.k8s_min_master_version}"
  network                  = "${google_compute_network.k8s.self_link}"
  subnetwork               = "${google_compute_subnetwork.nodes.self_link}"
  initial_node_count       = 1
  remove_default_node_pool = true
  project                  = "${google_project.project.project_id}"

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "${var.k8s_master_cidr}"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.nodes.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.nodes.secondary_ip_range.1.range_name}"
  }

  // Basic auth is disabled by setting user/pass to empty strings
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  master_authorized_networks_config {
    cidr_blocks = [
      "${var.k8s_master_whitelist_cidrs}",
      "${var.additional_k8s_master_whitelist_cidrs}",
    ]
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "main-node-pool" {
  name       = "main-node-pool"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.runner-benchmark.name}"
  node_count = 1
  project    = "${google_project.project.project_id}"
  version    = "${var.k8s_min_master_version}"

  lifecycle {
    ignore_changes = ["node_count", "version"]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 20
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "custom-4-4096"

    oauth_scopes = [
      "compute-rw",
    ]

    service_account = "${google_service_account.compute.email}"
    tags            = ["k8s-node", "default-node-pool"]
  }
}
