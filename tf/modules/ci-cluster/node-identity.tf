##[>] 🤖🤖
resource "google_service_account" "node" {
  project      = google_project.ci.project_id
  account_id   = "gke-node"
  display_name = "GKE CI node"
}

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
