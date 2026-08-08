##[>] 🤖🤖
#[why] CI variables for the iac applier, on the iac project itself, protected: exposed only to
#   protected-ref pipelines (main), so a Developer-token branch push cannot read them.
#   masked: hidden in job logs. values come from sensitive TF_VAR_* inputs; empty -> variable
#   created empty + unmasked (GitLab rejects masked empty), populate in the UI. once a real
#   TF_VAR_* value is applied it is masked.
resource "gitlab_project_variable" "ci_gitlab_token" {
  project   = var.iac_project_path
  key       = "TF_GITLAB_TOKEN"
  value     = var.ci_gitlab_token
  masked    = var.ci_gitlab_token != ""
  protected = true
}

#[why] GOOGLE_CREDENTIALS is NOT managed here: it holds the out-of-band tf applier SA key
#   (created via gcloud, set via glab), kept outside the state this applier applies.

resource "gitlab_project_variable" "ci_github_token" {
  project   = var.iac_project_path
  key       = "GITHUB_TOKEN"
  value     = var.ci_github_token
  masked    = var.ci_github_token != ""
  protected = true
}

#[why] self-managed bootstrap: first apply runs locally with these exported as TF_VAR_*, which lands them as CI variables for every later CI plan/apply. protected: all iac refs are protected (protect_all_branches), so they still flow to MR-branch plan jobs
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
