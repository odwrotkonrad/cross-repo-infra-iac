##[>] 🤖🤖
resource "google_project" "auth" {
  name            = "auth"
  project_id      = var.project_id
  folder_id       = google_folder.sandbox.folder_id
  billing_account = var.gcp_billing_account
}

resource "google_project_service" "secretmanager" {
  project = google_project.auth.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "iam" {
  project = google_project.auth.project_id
  service = "iam.googleapis.com"
}
##[<] 🤖🤖
