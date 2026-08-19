##[>] 🤖🤖
#[what] the identity job pods run as, so infra/oci-images can publish without a key
#[why] the runner manager's workload identity binding covers the manager pod only. job pods set
#   no service account, so they ran as the namespace `default`, bound to nothing. granting that
#   account would grant every workload that also defaults, hence a named one
resource "google_service_account" "ci_job" {
  project      = google_project.ci.project_id
  account_id   = "ci-job"
  display_name = "GitLab CI job pod"
}

resource "kubernetes_service_account_v1" "ci_job" {
  metadata {
    name      = var.job_service_account
    namespace = var.runner_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.ci_job.email
    }
  }

  depends_on = [kubernetes_namespace_v1.runner]
}

resource "google_service_account_iam_member" "ci_job_workload_identity" {
  service_account_id = google_service_account.ci_job.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_container_cluster.ci.workload_identity_config[0].workload_pool}[${var.runner_namespace}/${var.job_service_account}]"
}

#[why] the node identity covers only what the kubelet pulls, which is the job's own `image:`. a
#   pull issued inside a job runs as this account, so a build fetching its own base image or a
#   tool image needs reader here too, on every repository it may read from
resource "google_artifact_registry_repository_iam_member" "ci_job_reader" {
  for_each = {
    ci               = google_artifact_registry_repository.ci.name
    remote-gitlab    = google_artifact_registry_repository.remote_gitlab.name
    remote-dockerhub = google_artifact_registry_repository.remote_dockerhub.name
  }

  project    = google_project.ci.project_id
  location   = var.region
  repository = each.value
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.ci_job.email}"
}

#[why] writer on our own repository only: a compromised job must not be able to alter the cached
#   third-party images every pipeline trusts
resource "google_artifact_registry_repository_iam_member" "ci_job_writer" {
  project    = google_project.ci.project_id
  location   = var.region
  repository = google_artifact_registry_repository.ci.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ci_job.email}"
}
##[<] 🤖🤖
