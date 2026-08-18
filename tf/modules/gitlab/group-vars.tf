##[>] 🤖🤖
resource "gitlab_project_variable" "ci_gitlab_token" {
  project   = var.iac_project_path
  key       = "TF_GITLAB_TOKEN"
  value     = var.ci_gitlab_token
  masked    = var.ci_gitlab_token != ""
  protected = true
}

resource "gitlab_project_variable" "google_credentials" {
  project   = var.iac_project_path
  key       = "GOOGLE_CREDENTIALS"
  value     = var.ci_google_credentials
  masked    = var.ci_google_credentials != ""
  protected = false
}

resource "gitlab_project_variable" "ci_github_token" {
  project   = var.iac_project_path
  key       = "GITHUB_TOKEN"
  value     = var.github_token
  masked    = var.github_token != ""
  protected = true
}

resource "gitlab_project_variable" "ci_op_service_account_token" {
  project   = var.iac_project_path
  key       = "TF_VAR_op_service_account_token"
  value     = var.ci_op_service_account_token
  masked    = var.ci_op_service_account_token != ""
  protected = true
}

resource "gitlab_project_variable" "ci_gcp_billing_account" {
  project   = var.iac_project_path
  key       = "TF_VAR_gcp_billing_account"
  value     = var.ci_gcp_billing_account
  masked    = var.ci_gcp_billing_account != ""
  protected = true
}
##[<] 🤖🤖
