##[>] 🤖🤖
#[why] own project, not the sandbox auth one: CI spend reads as one figure in billing reports
#   grouped by project, and a compromised runner cannot reach sandbox identity secrets
resource "google_project" "ci" {
  name            = "ci-cluster"
  project_id      = var.project_id
  folder_id       = var.dev_folder_name
  billing_account = var.gcp_billing_account
}

resource "google_project_service" "container" {
  project = google_project.ci.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  project = google_project.ci.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = google_project.ci.project_id
  service = "secretmanager.googleapis.com"
}
##[<] 🤖🤖
