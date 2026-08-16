##[>] 🤖🤖
resource "google_compute_network" "ci" {
  project                 = google_project_service.compute.project
  name                    = var.cluster_name
  auto_create_subnetworks = false
}

#[why] secondary ranges carry pods and services: VPC-native (alias IP) clusters need them declared here
resource "google_compute_subnetwork" "ci" {
  project       = google_project_service.compute.project
  name          = var.cluster_name
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

#[why] private nodes have no external IP, so egress (image pulls, the GitLab API, package registries)
#   goes through this NAT. one NAT serves every node in the region, which is what decouples pool size
#   from the IN_USE_ADDRESSES quota that previously capped the cluster at one worker
resource "google_compute_router" "ci" {
  project = google_project_service.compute.project
  name    = var.cluster_name
  region  = var.region
  network = google_compute_network.ci.id
}

resource "google_compute_router_nat" "ci" {
  project = google_project_service.compute.project
  name    = var.cluster_name
  router  = google_compute_router.ci.name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
##[<] 🤖🤖
