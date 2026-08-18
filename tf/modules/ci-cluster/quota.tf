##[>] 🤖🤖
resource "google_project_service" "cloudquotas" {
  project = google_project.ci.project_id
  service = "cloudquotas.googleapis.com"
}

locals {
  ci_pool_vcpus = {
    for key, pool in var.ci_node_pools :
    key => tonumber(element(split("-", pool.machine_type), length(split("-", pool.machine_type)) - 1))
  }

  ci_worst_case_vcpus = sum([
    for key, pool in var.ci_node_pools :
    local.ci_pool_vcpus[key] * (pool.fallback ? var.ci_max_nodes_per_pool_fallback : var.ci_max_nodes_per_pool)
  ])

  manager_vcpus = tonumber(element(split("-", var.manager_machine_type), length(split("-", var.manager_machine_type)) - 1))
}

check "ci_caps_fit_cpu_quota" {
  assert {
    condition     = local.ci_worst_case_vcpus + local.manager_vcpus <= var.ci_cpu_quota
    error_message = "node caps promise ${local.ci_worst_case_vcpus} + ${local.manager_vcpus} manager vcpu, over the ${var.ci_cpu_quota} cpu quota: lower ci_max_nodes_per_pool or ci_max_nodes_per_pool_fallback, or raise ci_cpu_quota (a quota increase google reviews)"
  }
}

resource "google_cloud_quotas_quota_preference" "cpus_all_regions" {
  parent   = "projects/${google_project.ci.project_id}"
  name     = "compute-cpus-all-regions"
  service  = "compute.googleapis.com"
  quota_id = "CPUS-ALL-REGIONS-per-project"

  contact_email = var.quota_contact_email
  justification = "Self-hosted GitLab CI runners on GKE. Two autoscaling node pools (linux-amd64, linux-arm64) of e2-standard-4/c4a-standard-4 nodes, capped at 8 nodes each, plus one e2-standard-2 manager. Release builds request 3 vCPU each and currently fail to schedule because the autoscaler cannot obtain nodes within the 32 vCPU limit."

  quota_config {
    preferred_value = var.ci_cpu_quota
  }

  depends_on = [
    google_project_service.cloudquotas,
    google_project_iam_member.ci_applier,
  ]
}
##[<] 🤖🤖
