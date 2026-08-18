##[>] 🤖🤖
resource "google_folder_iam_member" "dev_viewer" {
  folder = var.dev_folder_name
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sandbox.email}"
}

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
