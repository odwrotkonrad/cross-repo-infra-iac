##[>] 🤖🤖
resource "google_compute_network" "ci" {
  project                 = google_project_service.compute.project
  name                    = "ci"
  auto_create_subnetworks = false
}

#[why] secondary ranges carry pods and services: VPC-native (alias IP) clusters need them declared here
resource "google_compute_subnetwork" "ci" {
  project       = google_project_service.compute.project
  name          = "ci"
  region        = var.region
  network       = google_compute_network.ci.id
  ip_cidr_range = "10.0.0.0/20"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.0.0/20"
  }
}
##[<] 🤖🤖
