##[>] 🤖🤖
resource "google_project" "ci" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.gcp_org_id
  billing_account = var.gcp_billing_account

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

resource "google_project_service" "artifactregistry" {
  project = google_project.ci.project_id
  service = "artifactregistry.googleapis.com"
}


resource "google_project_iam_member" "ci_applier" {
  for_each = toset([
    "roles/compute.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
    "roles/cloudquotas.admin",
    "roles/artifactregistry.admin",
  ])

  project = google_project.ci.project_id
  role    = each.value
  member  = var.gcp_ci_member
}
##[<] 🤖🤖
