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
##[<] 🤖🤖
