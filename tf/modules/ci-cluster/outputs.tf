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
