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


  #[why] OPTIMIZE_UTILIZATION: GKE exposes no scale-down timer (no --scale-down-unneeded-time in
  #   gcloud or terraform), only this profile. it sheds an unneeded node within about two minutes
  #   rather than holding it ten, trading a 60-120s cold start on the next job for paying nothing
  #   between bursts. BALANCED is the alternative if cold starts start to hurt
  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  #[why] deletion_protection defaults on and would block `terraform destroy` of a CI cluster that is
  #   meant to be disposable (the documented response to a budget alert)
  deletion_protection = false
}

#[why] always-on: this pool never scales to zero, because the manager pod it hosts is what notices a
#   queued job at all. spot by default (see manager_spot): a preemption costs a minute or two of
#   dispatch and orphans any in-flight job, which is the accepted trade for ~70% off the one node
#   that runs continuously
resource "google_container_node_pool" "manager" {
  project    = google_project_service.container.project
  name       = "manager"
  location   = var.zone
  cluster    = google_container_cluster.ci.name
  node_count = 1

  #[why] the manager needs no external IP either: it long-polls GitLab out through the Cloud NAT
  network_config {
    enable_private_nodes = true
  }

  node_config {
    machine_type = var.manager_machine_type
    spot         = var.manager_spot
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

  #[why] private nodes take no external IP, so pool size is bounded by max_node_count rather than the
  #   region's IN_USE_ADDRESSES quota. that quota is 8 and one public IP per node hit it at a single
  #   worker, leaving scale-up in QUOTA_EXCEEDED backoff and every queued job Pending. egress runs
  #   through the Cloud NAT in network.tf, which is all these nodes need: runners poll GitLab out,
  #   nothing dials in. set per pool, not on the cluster, where it would force a full replacement
  network_config {
    enable_private_nodes = true
  }

  node_config {
    machine_type = each.value.machine_type
    spot         = true
    disk_size_gb = var.ci_disk_size_gb
    #[why] C4A (Axion) rejects pd-balanced outright, taking hyperdisk-balanced only, so a hardcoded
    #   pd-balanced failed every arm64 node creation with "disk type cannot be used by c4a-standard-4"
    #   and left the pool permanently at zero. per pool, since the amd64 e2 machines predate hyperdisk
    #   and stay on pd-balanced
    disk_type = each.value.disk_type

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

    #[why] GKE taints every arm64 pool kubernetes.io/arch=arm64:NoSchedule whether or not terraform
    #   asks, so declaring it changes no behavior and only makes it visible: a reader sees why arm64
    #   job pods need a second toleration (runner-deploy.tf) instead of learning it from a job that
    #   waited for a pod no node would accept. amd64 carries no such taint, hence the conditional
    dynamic "taint" {
      for_each = each.value.arch == "arm64" ? [1] : []

      content {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
      }
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
