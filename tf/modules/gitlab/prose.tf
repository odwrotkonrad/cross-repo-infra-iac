##[>] 🤖🤖
resource "gitlab_project_access_token" "prose_tagger" {
  project      = module.l0.project_ids["${var.token_group_path}/prose"]
  name         = "prose-tag-minter"
  scopes       = ["api", "write_repository"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

resource "gitlab_project_variable" "prose_tag_token" {
  project   = module.l0.project_ids["${var.token_group_path}/prose"]
  key       = "PROSE_TAG_TOKEN"
  value     = gitlab_project_access_token.prose_tagger.token
  masked    = true
  protected = true
}
##[<] 🤖🤖
