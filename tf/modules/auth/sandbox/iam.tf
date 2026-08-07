##[>] 🤖🤖
#[why] placeholder read access on the dev folder until dev-plane access is designed
resource "google_folder_iam_member" "dev_viewer" {
  folder = google_folder.dev.name
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sandbox.email}"
}
##[<] 🤖🤖
