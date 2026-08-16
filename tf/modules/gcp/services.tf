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

#[why] the ci-cluster module raises the cpu quota on its own project, but the api-enablement check
#   lands on the provider's quota project, not the target: enabling cloudquotas only on the target
#   still failed with "Cloud Quotas API has not been used in project 522456158618", which is this one
resource "google_project_service" "cloudquotas" {
  project            = var.gcp_project
  service            = "cloudquotas.googleapis.com"
  disable_on_destroy = false
}
##[<] 🤖🤖
