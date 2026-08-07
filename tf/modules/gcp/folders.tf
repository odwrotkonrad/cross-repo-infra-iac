##[>] 🤖🤖
resource "google_folder" "sandbox" {
  display_name = "sandbox"
  parent       = "organizations/${var.gcp_org_id}"
}

resource "google_folder" "dev" {
  display_name = "dev"
  parent       = google_folder.sandbox.name
}
##[<] 🤖🤖
