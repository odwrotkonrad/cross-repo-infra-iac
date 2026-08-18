##[>] 🤖🤖
resource "google_container_cluster" "ci" {
  project  = google_project_service.container.project
  name     = var.cluster_name
  location = var.zone

  network    = google_compute_network.ci.id
  subnetwork = google_compute_subnetwork.ci.id

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

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

  deletion_protection = false
}

resource "google_container_node_pool" "manager" {
  project    = google_project_service.container.project
  name       = "manager"
  location   = var.zone
  cluster    = google_container_cluster.ci.name
  node_count = 1

  network_config {
    enable_private_nodes = true
  }

  node_config {
    machine_type = var.manager_machine_type
    spot         = var.manager_spot
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

resource "google_container_node_pool" "ci" {
  for_each = var.ci_node_pools

  project  = google_project_service.container.project
  name     = each.key
  location = var.zone
  cluster  = google_container_cluster.ci.name

  autoscaling {
    min_node_count  = 0
    max_node_count  = each.value.fallback ? var.ci_max_nodes_per_pool_fallback : var.ci_max_nodes_per_pool
    location_policy = "ANY"
  }

  network_config {
    enable_private_nodes = true
  }

  node_config {
    machine_type = each.value.machine_type
    spot         = true
    disk_size_gb = var.ci_disk_size_gb
    disk_type    = each.value.disk_type

    service_account = google_service_account.node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      "ci-arch" = each.value.arch
    }

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
