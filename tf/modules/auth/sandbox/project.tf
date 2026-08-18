##[>] 🤖🤖
resource "google_project" "auth" {
  name            = "auth"
  project_id      = var.project_id
  folder_id       = var.sandbox_folder_id
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

resource "google_project_service" "orgpolicy" {
  project = google_project.auth.project_id
  service = "orgpolicy.googleapis.com"
}

resource "google_org_policy_policy" "allow_sa_key_creation" {
  name   = "projects/${google_project.auth.project_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "projects/${google_project.auth.project_id}"

  spec {
    rules {
      enforce = "FALSE"
    }
  }

  depends_on = [google_project_service.orgpolicy]
}
##[<] 🤖🤖
