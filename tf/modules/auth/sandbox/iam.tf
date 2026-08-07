##[>] 🤖🤖
#[why] placeholder read access on the dev folder until dev-plane access is designed
resource "google_folder_iam_member" "dev_viewer" {
  folder = var.dev_folder_name
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sandbox.email}"
}
##[<] 🤖🤖
