##[>] 🤖🤖
#[why] placeholder read access on the dev folder until dev-plane access is designed
resource "google_folder_iam_member" "dev_viewer" {
  folder = var.dev_folder_name
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sandbox.email}"
}

#[why] the CI applier manages this project's secrets, SA and services on main applies, and refreshes them (incl. secret version payloads) on every plan
resource "google_project_iam_member" "ci" {
  for_each = toset([
    "roles/secretmanager.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ])

  project = google_project.auth.project_id
  role    = each.value
  member  = var.ci_member
}
##[<] 🤖🤖
