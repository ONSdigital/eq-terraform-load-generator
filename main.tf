terraform {
  backend "gcs" {
    bucket = "eq-terraform-load-generator-tfstate"
  }
}

provider "google" {
  region = var.region
}

output "region" {
  value = var.region
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_compute_network" "k8s" {
  depends_on              = [google_project_service.compute]
  name                    = "k8s"
  auto_create_subnetworks = "true"
  project                 = var.project_id
}

// GKE

# service account for compute engine instances
resource "google_service_account" "compute" {
  account_id   = "compute"
  display_name = "Compute Engine service account"
  project      = var.project_id
}

resource "google_project_iam_member" "compute" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.compute.email}"
}

resource "google_container_cluster" "runner-benchmark" {
  name                     = "runner-benchmark"
  description              = "Kubernetes Cluster - Dev Benchmark environment"
  location                 = var.region
  min_master_version       = var.k8s_min_master_version
  initial_node_count       = 1
  remove_default_node_pool = true
  project                  = var.project_id
  network                  = google_compute_network.k8s.self_link

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "main-node-pool" {
  name       = "main-node-pool"
  location   = var.region
  cluster    = google_container_cluster.runner-benchmark.name
  node_count = 1
  project    = var.project_id
  version    = var.k8s_min_master_version

  lifecycle {
    ignore_changes = [
      node_count,
      version,
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = var.k8s_autoscaling_max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.k8s_machine_type

    oauth_scopes = [
      "compute-rw",
      "storage-rw",
      "logging-write",
      "monitoring",
    ]

    service_account = google_service_account.compute.email
    tags            = ["k8s-node", "default-node-pool"]
  }
}

resource "google_storage_bucket" "benchmark-output-storage" {
  name          = "${var.project_id}-outputs"
  location      = var.region
  force_destroy = "true"
  project       = var.project_id

  retention_policy {
    is_locked        = false
    retention_period = 31536000
  }
}

output "benchmark-output-storage" {
  value = google_storage_bucket.benchmark-output-storage.name
}
