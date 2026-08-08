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
##[<] 🤖🤖
