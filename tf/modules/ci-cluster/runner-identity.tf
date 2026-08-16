##[>] 🤖🤖
#[why] one runner per architecture and size: the tag a job carries selects both, e.g.
#   gke-linux-arm64-small. the default size also answers the bare gke-linux-<arch> tag, so a job that
#   does not care about size needs no size tag. group-level, so a new repo needs no runner work.
#   untagged false: nothing lands on paid CI capacity by accident
locals {
  runner_variants = {
    for pair in setproduct(keys(var.ci_node_pools), keys(var.job_sizes)) :
    "${pair[0]}-${pair[1]}" => {
      pool = pair[0]
      arch = var.ci_node_pools[pair[0]].arch
      size = pair[1]
    }
  }
}

resource "gitlab_user_runner" "ci" {
  for_each = local.runner_variants

  runner_type = "group_type"
  group_id    = var.gitlab_group_id
  description = "gke ${each.value.arch} ${each.value.size}"
  tag_list = concat(
    ["gke-linux-${each.value.arch}-${each.value.size}"],
    each.value.size == var.job_default_size ? ["gke-linux-${each.value.arch}"] : [],
  )
  untagged = false
}

resource "google_service_account" "runner" {
  project      = google_project.ci.project_id
  account_id   = "gitlab-runner"
  display_name = "GitLab runner manager"
}

#[why] the k8s service account the runner runs as impersonates the GCP SA through workload identity:
#   no key file is ever created, unlike the sandbox identity which needs a long-lived JSON key
resource "google_service_account_iam_member" "runner_workload_identity" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.workloadIdentityUser"
  #[why] the pool comes from the cluster, not the project id: it only exists once a cluster with
  #   workload identity is created, and referencing the cluster is what orders this after it
  member = "serviceAccount:${google_container_cluster.ci.workload_identity_config[0].workload_pool}[${var.runner_namespace}/${var.runner_service_account}]"
}
##[<] 🤖🤖
