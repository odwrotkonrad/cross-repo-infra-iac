##[>] 🤖🤖
resource "gitlab_group_access_token" "control" {
  group        = var.gitlab_group_id
  name         = "ko-automation"
  scopes       = ["api", "write_repository", "read_repository"]
  access_level = "maintainer"
  expires_at   = var.token_expires_at
}

resource "gitlab_project_variable" "control_gitlab_token" {
  project   = var.control_project_path
  key       = "REPO_VAR_CONTROL_GITLAB_TOKEN"
  value     = gitlab_group_access_token.control.token
  masked    = true
  protected = true
}

resource "gitlab_project_variable" "automation_reviewer" {
  project = var.control_project_path
  key     = "REPO_VAR_AUTOMATION_REVIEWER"
  value   = var.automation_reviewer
  masked  = false
}
##[<] 🤖🤖
