##[>] 🤖🤖
locals {
  ci_arches = toset([for p in var.ci_node_pools : p.arch])

  runner_variants = {
    for pair in setproduct(local.ci_arches, keys(var.job_sizes)) :
    "linux-${pair[0]}-${pair[1]}" => {
      arch = pair[0]
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

resource "google_service_account_iam_member" "runner_workload_identity" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_container_cluster.ci.workload_identity_config[0].workload_pool}[${var.runner_namespace}/${var.runner_service_account}]"
}
##[<] 🤖🤖
