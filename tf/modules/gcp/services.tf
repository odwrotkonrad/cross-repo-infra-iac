##[>] 🤖🤖
#[why] quota-project APIs the applier calls: cloudresourcemanager for folders/projects, cloudbilling for the billing association. disable_on_destroy false: other consumers of the shared quota project must not lose the API on teardown
resource "google_project_service" "cloudresourcemanager" {
  project            = var.gcp_project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbilling" {
  project            = var.gcp_project
  service            = "cloudbilling.googleapis.com"
  disable_on_destroy = false
}
##[<] 🤖🤖
