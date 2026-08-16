##[>] 🤖🤖
#[why] zonal, not regional: CI tolerates a zone outage, and a regional cluster triples node count
#   for the same work. optimize-utilization + a short unneeded-time empties the CI pools quickly:
#   the cold start on the next job is the accepted trade for not paying for idle nodes
resource "google_container_cluster" "ci" {
  project  = google_project_service.container.project
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.ci.id
  subnetwork = google_compute_subnetwork.ci.id

  #[why] the default pool is replaced by the explicit pools below, but a cluster cannot be created without one
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  #[why] workload identity lets the runner read its secrets with no service account key file on disk
  workload_identity_config {
    workload_pool = "${google_project.ci.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  #[why] deletion_protection defaults on and would block `terraform destroy` of a CI cluster that is
  #   meant to be disposable (the documented response to a budget alert)
  deletion_protection = false
}

#[why] always-on and not spot: the runner manager pod dispatches every job, so it must survive
#   preemption and must still be running when both CI pools sit at zero
resource "google_container_node_pool" "manager" {
  project    = google_project_service.container.project
  name       = "manager"
  location   = var.zone
  cluster    = google_container_cluster.ci.name
  node_count = 1

  node_config {
    machine_type = var.manager_machine_type
    #[why] the manager holds no build data: it dispatches jobs and streams logs
    disk_size_gb = 20
    disk_type    = "pd-balanced"

    service_account = google_service_account.node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

#[why] one pool per architecture: job pods select their pool by nodeSelector, so an arm64 job never
#   lands on amd64. spot for both, scaling from zero. max_node_count is the real cost ceiling:
#   billing alerts arrive hours late, this cannot be exceeded at all
resource "google_container_node_pool" "ci" {
  for_each = var.ci_node_pools

  project  = google_project_service.container.project
  name     = each.key
  location = var.zone
  cluster  = google_container_cluster.ci.name

  autoscaling {
    min_node_count = 0
    max_node_count = var.ci_max_nodes_per_pool
  }

  node_config {
    machine_type = each.value.machine_type
    spot         = true
    disk_size_gb = var.ci_disk_size_gb
    disk_type    = "pd-balanced"

    service_account = google_service_account.node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      "ci-arch" = each.value.arch
    }

    #[why] tainted so only job pods tolerating it land here: nothing else may occupy paid CI capacity
    taint {
      key    = "ci"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
##[<] 🤖🤖
