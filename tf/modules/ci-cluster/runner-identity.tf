##[>] 🤖🤖
#[why] group-level runner: one registration serves every project under konradodwrot, so a new repo
#   needs no runner work. tags bind jobs to an architecture; untagged jobs must not land here by accident
resource "gitlab_user_runner" "ci" {
  for_each = var.ci_node_pools

  runner_type = "group_type"
  group_id    = var.gitlab_group_id
  description = "gke ${each.value.arch}"
  tag_list    = ["gke-linux-${each.value.arch}"]
  untagged    = false
}

resource "google_secret_manager_secret" "runner_token" {
  for_each = var.ci_node_pools

  project   = google_project_service.secretmanager.project
  secret_id = "gitlab-runner-token-${each.value.arch}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "runner_token" {
  for_each = var.ci_node_pools

  secret      = google_secret_manager_secret.runner_token[each.key].id
  secret_data = gitlab_user_runner.ci[each.key].token
}

resource "google_service_account" "runner" {
  project      = google_project.ci.project_id
  account_id   = "gitlab-runner"
  display_name = "GitLab runner manager"
}

#[why] project-scoped accessor, mirroring the sandbox pattern: one grant covers every runner secret,
#   and it reaches nothing outside this project
resource "google_project_iam_member" "runner_secret_accessor" {
  project = google_project.ci.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

#[why] the k8s service account the runner runs as impersonates the GCP SA through workload identity:
#   no key file is ever created, unlike the sandbox identity which needs a long-lived JSON key
resource "google_service_account_iam_member" "runner_workload_identity" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_project.ci.project_id}.svc.id.goog[${var.runner_namespace}/${var.runner_service_account}]"
}
##[<] 🤖🤖
