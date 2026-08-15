##[>] 🤖🤖
resource "gitlab_group_access_token" "control" {
  group        = var.gitlab_group_id
  name         = "control-maintainer"
  scopes       = ["api", "write_repository", "read_repository"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

resource "gitlab_project_variable" "control_gitlab_token" {
  project   = var.control_project_path
  key       = "CONTROL_GITLAB_TOKEN"
  value     = gitlab_group_access_token.control.token
  masked    = true
  protected = true
}
##[<] 🤖🤖
