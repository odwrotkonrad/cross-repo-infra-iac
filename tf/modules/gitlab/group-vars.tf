##[>] 🤖🤖
resource "gitlab_project_variable" "ci_gitlab_token" {
  project   = local.project_ids[var.iac_project_path]
  key       = "REPO_VAR_GITLAB_TOKEN"
  value     = var.ci_gitlab_token
  masked    = var.ci_gitlab_token != ""
  protected = true
}

resource "gitlab_project_variable" "google_credentials" {
  project   = local.project_ids[var.iac_project_path]
  key       = "REPO_VAR_GOOGLE_CREDENTIALS"
  value     = var.ci_google_credentials
  masked    = var.ci_google_credentials != ""
  protected = false
}

resource "gitlab_project_variable" "ci_github_token" {
  project   = local.project_ids[var.iac_project_path]
  key       = "REPO_VAR_GITHUB_TOKEN"
  value     = var.github_token
  masked    = var.github_token != ""
  protected = true
}

resource "gitlab_project_variable" "ci_op_service_account_token" {
  project   = local.project_ids[var.iac_project_path]
  key       = "REPO_VAR_OP_SERVICE_ACCOUNT_TOKEN"
  value     = var.ci_op_service_account_token
  masked    = var.ci_op_service_account_token != ""
  protected = true
}

resource "gitlab_project_variable" "ci_gcp_billing_account" {
  project   = local.project_ids[var.iac_project_path]
  key       = "REPO_VAR_GCP_BILLING_ACCOUNT"
  value     = var.ci_gcp_billing_account
  masked    = var.ci_gcp_billing_account != ""
  protected = true
}
##[<] 🤖🤖
