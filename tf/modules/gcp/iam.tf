##[>] 🤖🤖
#[why] organizationAdmin can manage IAM but not create folders: the applier grants itself folderCreator, non-authoritative per member/role
resource "google_organization_iam_member" "applier_folder_creator" {
  org_id = var.gcp_org_id
  role   = "roles/resourcemanager.folderCreator"
  member = var.gcp_applier_member
}

#[why] setting the project-level org-policy override below the org requires policyAdmin, which organizationAdmin does not carry
resource "google_organization_iam_member" "applier_org_policy_admin" {
  org_id = var.gcp_org_id
  role   = "roles/orgpolicy.policyAdmin"
  member = var.gcp_applier_member
}

#[why] CI plan refreshes the google_project_service resources: the CI SA needs services.list on the quota project
resource "google_project_iam_member" "ci_service_usage_viewer" {
  project = var.gcp_project
  role    = "roles/serviceusage.serviceUsageViewer"
  member  = var.gcp_ci_member
}

#[why] CI plan refreshes the org and project IAM member grants above: securityReviewer carries getIamPolicy on every resource below the org, read-only
resource "google_organization_iam_member" "ci_iam_viewer" {
  org_id = var.gcp_org_id
  role   = "roles/iam.securityReviewer"
  member = var.gcp_ci_member
}

#[why] CI plan refreshes the folder and project resources: browser carries get/list on the resource hierarchy, read-only
resource "google_organization_iam_member" "ci_browser" {
  org_id = var.gcp_org_id
  role   = "roles/browser"
  member = var.gcp_ci_member
}

#[why] CI plan refreshes the project-level org policy override on the sandbox auth project
resource "google_organization_iam_member" "ci_org_policy_viewer" {
  org_id = var.gcp_org_id
  role   = "roles/orgpolicy.policyViewer"
  member = var.gcp_ci_member
}

#[why] the quota project is org-less (no parent), org grants never reach it: the IAM policy read needs a direct project grant
resource "google_project_iam_member" "ci_iam_viewer_quota_project" {
  project = var.gcp_project
  role    = "roles/iam.securityReviewer"
  member  = var.gcp_ci_member
}

#[why] a quota preference is submitted against the provider's quota project, not only the project
#   whose quota is raised: the ci-cluster module grants cloudquotas.admin on its own project, and
#   this is the matching grant on this one, without which the call is refused here instead
resource "google_project_iam_member" "ci_cloudquotas_admin" {
  project = var.gcp_project
  role    = "roles/cloudquotas.admin"
  member  = var.gcp_ci_member
}

#[why] the CI applier manages the monitoring notification channels the budget alerts on. scoped to
#   the quota project where those channels live, not org-wide
resource "google_project_iam_member" "ci_monitoring_editor" {
  project = var.gcp_project
  role    = "roles/monitoring.editor"
  member  = var.gcp_ci_member
}

#[why] budgets live on the billing account, not a project: without this the CI applier can plan the
#   budget but never read or write it
resource "google_billing_account_iam_member" "ci_billing_admin" {
  billing_account_id = var.gcp_billing_account
  role               = "roles/billing.admin"
  member             = var.gcp_ci_member
}

##[<] 🤖🤖
