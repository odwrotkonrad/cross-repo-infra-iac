##[>] 🤖🤖
resource "gitlab_group_access_token" "prose_tagger" {
  group        = module.l0.group_ids[var.token_group_path]
  name         = "prose-tag-minter"
  scopes       = ["api", "write_repository"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

resource "gitlab_project_variable" "prose_tag_token" {
  project   = module.l0.project_ids["${var.token_group_path}/prose"]
  key       = "PROSE_TAG_TOKEN"
  value     = gitlab_group_access_token.prose_tagger.token
  masked    = true
  protected = true
}
##[<] 🤖🤖
