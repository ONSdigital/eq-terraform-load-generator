terraform {
  backend "gcs" {
    bucket = "census-eq-terraform-tfstate"
  }
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "benchmark-${var.project_name}-"
}

provider "google" {
  region = "${var.region}"
}

output "region" {
  value = "${var.region}"
}

resource "google_project" "project" {
  name            = "${var.project_name}"
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

resource "google_compute_network" "k8s" {
  depends_on              = ["google_project_service.compute"]
  name                    = "k8s"
  auto_create_subnetworks = "true"
  project                 = "${google_project.project.project_id}"
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
  description              = "Kubernetes Cluster - Dev Benchmark environment"
  location                 = "${var.region}"
  min_master_version       = "${var.k8s_min_master_version}"
  initial_node_count       = 1
  remove_default_node_pool = true
  project                  = "${google_project.project.project_id}"
  network                  = "${google_compute_network.k8s.self_link}"

  // Basic auth is disabled by setting user/pass to empty strings
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
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
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "compute-rw",
      "logging-write",
      "monitoring"
    ]

    service_account = "${google_service_account.compute.email}"
    tags            = ["k8s-node", "default-node-pool"]
  }
}
