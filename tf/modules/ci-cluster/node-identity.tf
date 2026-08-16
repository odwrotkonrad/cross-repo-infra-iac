##[>] 🤖🤖
#[why] nodes must NOT run as the project's default compute SA: that identity holds Editor, and every
#   job container here is privileged, so anything reaching the metadata server would inherit it.
#   this SA carries only what a node needs to function: ship logs and metrics, pull images
resource "google_service_account" "node" {
  project      = google_project.ci.project_id
  account_id   = "gke-node"
  display_name = "GKE CI node"
}

#[why] exactly the GKE node baseline, nothing speculative. no artifactregistry.reader: every CI image
#   comes from the GitLab container registry, authenticated per job with CI_REGISTRY_PASSWORD, and the
#   only pipeline touching GCP (infra/iac) uses its own applier credential, not the node identity.
#   add a role here only when a job actually fails without it
resource "google_project_iam_member" "node" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])

  project = google_project.ci.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.node.email}"
}
##[<] 🤖🤖
