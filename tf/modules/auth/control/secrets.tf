##[>] 🤖🤖
resource "google_secret_manager_secret" "control_gitlab_token" {
  project   = var.gcp_project_id
  secret_id = "control-gitlab-group-token"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "control_gitlab_token" {
  secret      = google_secret_manager_secret.control_gitlab_token.id
  secret_data = gitlab_group_access_token.control.token
}
##[<] 🤖🤖
