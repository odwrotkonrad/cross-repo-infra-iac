##[>] 🤖🤖
resource "google_folder" "sandbox" {
  display_name = "sandbox"
  parent       = "organizations/${var.gcp_org_id}"

  depends_on = [
    google_project_service.cloudresourcemanager,
    google_project_service.cloudbilling,
  ]
}

resource "google_folder" "dev" {
  display_name = "dev"
  parent       = google_folder.sandbox.name
}
##[<] 🤖🤖
