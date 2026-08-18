##[>] 🤖🤖
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

resource "google_project_service" "orgpolicy" {
  project            = var.gcp_project
  service            = "orgpolicy.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "billingbudgets" {
  project            = var.gcp_project
  service            = "billingbudgets.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudquotas" {
  project            = var.gcp_project
  service            = "cloudquotas.googleapis.com"
  disable_on_destroy = false
}
##[<] 🤖🤖
