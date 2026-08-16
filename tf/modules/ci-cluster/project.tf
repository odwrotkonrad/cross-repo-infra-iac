##[>] 🤖🤖
#[why] pre-existing project adopted by import, not created here: its id, display name and org-level
#   placement predate this module and must be reproduced exactly, or terraform plans a replacement
#   that would destroy it. billing_account is the one thing this adds: GKE needs a billable project
resource "google_project" "ci" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.gcp_org_id
  billing_account = var.gcp_billing_account

  #[why] adopted, not owned: this project predates the config and may hold unrelated work, so
  #   removing it from config must be a state removal, never a destroy
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service" "container" {
  project = google_project.ci.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  project = google_project.ci.project_id
  service = "compute.googleapis.com"
}


#[why] the CI applier owns everything inside this project: network, cluster, node pools, service
#   accounts. granted here rather than org-wide, so its reach stops at the CI project's boundary
resource "google_project_iam_member" "ci_applier" {
  for_each = toset([
    "roles/compute.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    #[why] the runner cache bucket lives in this project: creating it and granting the runner access
    #   to it is the applier's work, still bounded by the project
    "roles/storage.admin",
  ])

  project = google_project.ci.project_id
  role    = each.value
  member  = var.gcp_ci_member
}
##[<] 🤖🤖
