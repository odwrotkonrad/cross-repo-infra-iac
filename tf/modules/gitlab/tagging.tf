##[>] 🤖🤖
#[why] one identity mints every repo's semver tags: a per-repo token would multiply credentials for
#   one capability. group-level so it reaches each project below, maintainer so it can push a tag to a
#   protected default branch
resource "gitlab_group_access_token" "tagger" {
  group        = module.l0.group_ids[var.token_group_path]
  name         = "tag-minter"
  scopes       = ["api", "write_repository"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

#[why] exposed per project rather than as a group variable: only the repos running tag-mint should
#   carry a credential that can push to any of them
resource "gitlab_project_variable" "tag_token" {
  for_each = toset(var.tagging_projects)

  project   = module.l0.project_ids["${var.token_group_path}/${each.value}"]
  key       = "REPO_VAR_TAG_TOKEN"
  value     = gitlab_group_access_token.tagger.token
  masked    = true
  protected = true
}
##[<] 🤖🤖
