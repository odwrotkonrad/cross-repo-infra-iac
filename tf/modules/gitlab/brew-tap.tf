##[>] 🤖🤖
resource "gitlab_project_access_token" "homebrew_tap" {
  project      = module.l0.project_ids["${var.token_group_path}/homebrew-tap"]
  name         = "go-modules-brew-publisher"
  scopes       = ["api"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

resource "gitlab_tag_protection" "go_modules" {
  project             = module.l0.project_ids["${var.token_group_path}/go-modules"]
  tag                 = "*"
  create_access_level = "developer"
}

resource "gitlab_project_variable" "homebrew_tap_project_id" {
  project   = module.l0.project_ids["${var.token_group_path}/go-modules"]
  key       = "HOMEBREW_TAP_PROJECT_ID"
  value     = module.l0.project_ids["${var.token_group_path}/homebrew-tap"]
  protected = true
}

resource "gitlab_project_variable" "homebrew_tap_token" {
  project   = module.l0.project_ids["${var.token_group_path}/go-modules"]
  key       = "HOMEBREW_TAP_TOKEN"
  value     = gitlab_project_access_token.homebrew_tap.token
  masked    = true
  protected = true
}
##[<] 🤖🤖
