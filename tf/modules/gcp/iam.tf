##[>] 🤖🤖
#[why] organizationAdmin can manage IAM but not create folders: the applier grants itself folderCreator, non-authoritative per member/role
resource "google_organization_iam_member" "applier_folder_creator" {
  org_id = var.gcp_org_id
  role   = "roles/resourcemanager.folderCreator"
  member = var.gcp_applier_member
}
##[<] 🤖🤖
