##[>] 🤖🤖
resource "google_organization_iam_member" "applier_folder_creator" {
  org_id = var.gcp_org_id
  role   = "roles/resourcemanager.folderCreator"
  member = var.gcp_applier_member
}

resource "google_organization_iam_member" "applier_org_policy_admin" {
  org_id = var.gcp_org_id
  role   = "roles/orgpolicy.policyAdmin"
  member = var.gcp_applier_member
}

resource "google_project_iam_member" "ci_service_usage_viewer" {
  project = var.gcp_project
  role    = "roles/serviceusage.serviceUsageViewer"
  member  = var.gcp_ci_member
}

resource "google_organization_iam_member" "ci_iam_viewer" {
  org_id = var.gcp_org_id
  role   = "roles/iam.securityReviewer"
  member = var.gcp_ci_member
}

resource "google_organization_iam_member" "ci_browser" {
  org_id = var.gcp_org_id
  role   = "roles/browser"
  member = var.gcp_ci_member
}

resource "google_organization_iam_member" "ci_org_policy_viewer" {
  org_id = var.gcp_org_id
  role   = "roles/orgpolicy.policyViewer"
  member = var.gcp_ci_member
}

resource "google_project_iam_member" "ci_iam_viewer_quota_project" {
  project = var.gcp_project
  role    = "roles/iam.securityReviewer"
  member  = var.gcp_ci_member
}

resource "google_project_iam_member" "ci_cloudquotas_admin" {
  project = var.gcp_project
  role    = "roles/cloudquotas.admin"
  member  = var.gcp_ci_member
}

resource "google_project_iam_member" "ci_monitoring_editor" {
  project = var.gcp_project
  role    = "roles/monitoring.editor"
  member  = var.gcp_ci_member
}

resource "google_billing_account_iam_member" "ci_billing_admin" {
  billing_account_id = var.gcp_billing_account
  role               = "roles/billing.admin"
  member             = var.gcp_ci_member
}

##[<] 🤖🤖
