resource "google_compute_global_address" "runner-benchmark" {
  depends_on = ["google_project_service.compute"]
  name       = "runner-benchmark"
  project    = "${google_project.project.project_id}"
}
