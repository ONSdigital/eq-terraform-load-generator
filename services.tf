resource "google_compute_global_address" "runner-benchmark" {
  depends_on = ["google_project_service.compute"]
  name       = "runner-benchmark"
  project    = "${google_project.project.project_id}"
}

resource "google_dns_record_set" "locust" {
  count = "${var.create_dns ? 1 : 0}"

  project = "${var.dns_project}"
  name    = "${var.locust_fully_qualified_domain_name}."
  type    = "A"
  ttl     = 60

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${google_compute_global_address.runner-benchmark.address}"]
}

resource "google_compute_managed_ssl_certificate" "locust" {
  count    = "${var.create_locust_ssl_cert ? 1 : 0}"
  provider = "google-beta"

  name       = "locust"
  project    = "${google_project.project.project_id}"
  depends_on = ["google_project_service.compute"]

  managed {
    domains = ["${var.locust_fully_qualified_domain_name}"]
  }
}

output "locust_fully_qualified_domain_name" {
  value = "${var.locust_fully_qualified_domain_name}"
}
