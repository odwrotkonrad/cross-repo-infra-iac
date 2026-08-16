##[>] 🤖🤖
#[why] the cluster autoscaler cannot add a node the project has no cpu quota for: it asks, compute
#   refuses, and it drops into backoff while job pods sit Pending until they time out. observed on a
#   che release, where the arm64 goreleaser job died on "0/4 nodes are available: 3 Insufficient cpu"
#   while the autoscaler carried errorCode QUOTA_EXCEEDED, Limit: 32.0 globally.
#   the pool caps promise far more than 32 vcpu: one pool at ci_max_nodes_per_pool x e2-standard-4 is
#   32 on its own, plus the manager, and there are two pools. this raises the quota to match what the
#   caps already allow, so the binding constraint is the cap in this module rather than an invisible
#   ceiling in another api
resource "google_project_service" "cloudquotas" {
  project = google_project.ci.project_id
  service = "cloudquotas.googleapis.com"
}

#[why] CPUS_ALL_REGIONS is global and per-project: it counts every running vcpu in this project across
#   every region, so it is the one ceiling both node pools and the manager draw from together
resource "google_cloud_quotas_quota_preference" "cpus_all_regions" {
  parent   = "projects/${google_project.ci.project_id}"
  name     = "compute-cpus-all-regions"
  service  = "compute.googleapis.com"
  quota_id = "CPUS-ALL-REGIONS-per-project"

  #[why] google requires a justification on every increase request: it is read by a human or an
  #   automated approver, so it states the workload rather than merely restating the number
  contact_email = var.quota_contact_email
  justification = "Self-hosted GitLab CI runners on GKE. Two autoscaling node pools (linux-amd64, linux-arm64) of e2-standard-4/c4a-standard-4 nodes, capped at ${var.ci_max_nodes_per_pool} nodes each, plus one e2-standard-2 manager. Release builds request 3 vCPU each and currently fail to schedule because the autoscaler cannot obtain nodes within the 32 vCPU limit."

  quota_config {
    preferred_value = var.ci_cpu_quota
  }

  #[why] both edges for the same reason the cache bucket carries one: nothing here references the
  #   applier's cloudquotas.admin grant, so terraform would otherwise create them concurrently and
  #   hit the 403 that the first cache-bucket apply died on
  depends_on = [
    google_project_service.cloudquotas,
    google_project_iam_member.ci_applier,
  ]
}
##[<] 🤖🤖
