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

#[why] dynamic port allocation, not the default static 64. static gives every node one fixed share
#   (64 rounded to 512 ports) no matter how many pods it hosts, but these nodes deliberately pack
#   many job pods each, and every pod pulls images and long-polls GitLab on its own connections.
#   a packed node exhausted its 512 ports and further connections were dropped, surfacing as
#   `dial tcp gitlab.com:443: i/o timeout` while pulling the helper image, failing the job in
#   prepare_script. dynamic lets a busy node grow to max_ports_per_vm and hand the ports back when
#   idle, so port supply follows pod count instead of being fixed at node size
resource "google_compute_router_nat" "ci" {
  project = google_project_service.compute.project
  name    = var.cluster_name
  router  = google_compute_router.ci.name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_dynamic_port_allocation = true
  min_ports_per_vm               = 128
  max_ports_per_vm               = 8192

  #[why] without logging, port exhaustion is invisible: a dropped connection looks like a network
  #   timeout in the job log and nowhere else. errors only, so a busy pipeline is not billed for a
  #   log line per connection
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
##[<] 🤖🤖
