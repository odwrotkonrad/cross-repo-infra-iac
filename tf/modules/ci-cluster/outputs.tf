##[>] 🤖🤖
output "project_id" {
  value = google_project.ci.project_id
}

output "cluster_name" {
  value = google_container_cluster.ci.name
}

output "cluster_location" {
  value = google_container_cluster.ci.location
}

output "runner_service_account_email" {
  value = google_service_account.runner.email
}

#[why] the helm release reads each runner's token from these secrets via workload identity
output "runner_token_secret_ids" {
  value = { for k, s in google_secret_manager_secret.runner_token : k => s.secret_id }
}

#[why] `gcloud container clusters get-credentials` line for the runbook: scaling pools to zero is the
#   documented response to a budget alert
output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.ci.name} --zone ${google_container_cluster.ci.location} --project ${google_project.ci.project_id}"
}

output "cluster_endpoint" {
  value = "https://${google_container_cluster.ci.endpoint}"
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.ci.master_auth[0].cluster_ca_certificate
  sensitive = true
}
##[<] 🤖🤖
