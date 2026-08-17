##[>] 🤖🤖
variable "project_id" {
  type = string
}

#[why] generic: this cluster hosts the gitlab runners today, but nothing about it is runner-specific.
#   workloads are separated by namespace, so a second one needs no new cluster
variable "cluster_name" {
  type    = string
  default = "workloads"
}

#[why] must match the adopted project's existing display name, or terraform plans a rename
variable "project_name" {
  type = string
}

#[why] the project sits directly under the organization, not in the sandbox/dev folder tree
variable "gcp_org_id" {
  type = string
}

variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

variable "gitlab_group_id" {
  type = string
}

#[why] the CI pipeline's applier identity, granted project-scoped admin on this project only
variable "gcp_ci_member" {
  type = string
}

#[why] us-central1: large long-established region at the lowest price tier, with the deepest spot
#   capacity. a zonal cluster has no second zone to fall back on, so capacity depth matters here
variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

#[why] 4 vCPU / 16 GB leaves ~3.6 vCPU / 12 GB once daemonsets take their share, fitting three
#   1 vCPU / 3 GB medium pods, so the node's fixed overhead is paid once per three jobs. cpu is what
#   binds: memory would allow four
variable "ci_node_pools" {
  type = map(object({
    arch         = string
    machine_type = string
    disk_type    = string
  }))
  default = {
    linux-amd64 = { arch = "amd64", machine_type = "e2-standard-4", disk_type = "pd-balanced" }
    linux-arm64 = { arch = "arm64", machine_type = "c4a-standard-4", disk_type = "hyperdisk-balanced" }
  }
}

#[why] 8 nodes x 3 medium pods = 24 job slots per pool, comfortably over the runner's 16-job
#   concurrency cap, so either architecture absorbs a full burst alone and concurrency is what binds
#   first. this stays the hard spend ceiling: billing alerts arrive hours late
variable "ci_max_nodes_per_pool" {
  type    = number
  default = 8
}

#[why] dind needs room for image layers and build context, but jobs are short and the node is
#   discarded after. 50 GB carries a dind build comfortably at half the disk cost of 100
variable "ci_disk_size_gb" {
  type    = number
  default = 50
}

#[why] e2-standard-2, measured twice: shared-core machines (e2-small, e2-medium) expose only 940m
#   allocatable regardless of their memory, and kube-system's own daemons request 861m of it, leaving
#   less than this pod's 100m. only a full-core machine has room. GKE's overhead is near-constant per
#   node, so shrinking the node shrinks only the part you can use
variable "manager_machine_type" {
  type    = string
  default = "e2-standard-2"
}

#[why] spot for the manager too, trading availability for ~70% of its cost. when preempted, nothing
#   dispatches jobs for the minute or two a replacement takes, and any in-flight job is orphaned:
#   the runner tracks running jobs in memory and a fresh manager does not adopt them. queued jobs are
#   unaffected, they simply wait. flip false if orphaned jobs become a nuisance
variable "manager_spot" {
  type    = bool
  default = true
}

#[why] namespaced per workload, so a future workload lands beside the runners rather than replacing them
variable "runner_namespace" {
  type    = string
  default = "ci-gitlab-runners"
}

variable "runner_service_account" {
  type    = string
  default = "gitlab-runner"
}

variable "gitlab_url" {
  type    = string
  default = "https://gitlab.com/"
}

#[why] 0.91.2 or newer: runners.configOverride, which writes config.toml verbatim and skips
#   registration, does not exist in older charts. on 0.71.0 the key was silently ignored and the
#   runner fell back to registering from a template, which rejects more than one [[runners]] entry
variable "runner_chart_version" {
  type    = string
  default = "0.91.2"
}

#[why] the helper image the runner injects into every job pod, pre-pulled per node (image-prepull.tf).
#   must track the runner version runner_chart_version deploys, or the daemonset warms a tag no job
#   asks for and every job pulls anyway. check with:
#   kubectl -n <ns> get deploy gitlab-runner -o jsonpath='{..containers[0].image}'
variable "runner_helper_version" {
  type    = string
  default = "19.2.2"
}

variable "runner_default_image" {
  type    = string
  default = "registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest"
}

#[why] 16 job pods, reached at 6 of the 8 nodes a pool allows at 3 pods each: the runner cap binds
#   before the node cap, leaving headroom rather than the two ceilings meeting exactly
variable "runner_concurrent" {
  type    = number
  default = 16
}

#[why] relative sizes, so a job asks for what it needs by name. medium matches the SaaS runner it
#   replaces (8 GB tier) and is the default. memory requests are half the limits: scheduling reserves
#   half of what a pod may consume, so a node hosts pods whose limits sum to twice its capacity, which
#   suits jobs that spike briefly and idle between spikes. over its memory limit a pod is killed
#   outright, so a starved job fails fast rather than crawling.
#   no cpu limit on purpose: a cpu limit throttles, which is exactly the slow-forever failure to avoid.
#   the cpu request still reserves and schedules, and under contention the kernel shares cpu in
#   proportion to requests, so a job runs as fast as spare capacity allows
variable "job_sizes" {
  type = map(object({
    cpu_request    = string
    memory_request = string
    memory_limit   = string
  }))
  default = {
    small  = { cpu_request = "500m", memory_request = "1Gi", memory_limit = "2Gi" }
    medium = { cpu_request = "1000m", memory_request = "3Gi", memory_limit = "6Gi" }
    big    = { cpu_request = "3", memory_request = "6Gi", memory_limit = "12Gi" }
  }
}

#[why] the size a job gets when its tag names none
variable "job_default_size" {
  type    = string
  default = "medium"
}

#[why] 72 = both pools at their cap plus the manager, with headroom: 8 x 4 vcpu amd64, 8 x 4 vcpu
#   arm64, one 2 vcpu manager is 66, and a node being replaced can be counted twice for a moment.
#   sized off ci_max_nodes_per_pool on purpose, so the node cap stays the real ceiling and this quota
#   never becomes a second, invisible one. raising the node cap means raising this with it
variable "ci_cpu_quota" {
  type    = number
  default = 72
}

#[why] google requires a contact address on a quota increase request, and rejects the request without
#   one. no default: a wrong address here means an approval nobody sees
variable "quota_contact_email" {
  type = string
}

#[why] 1 day, because a longer window buys almost nothing: every pipeline rewrites the keys it uses,
#   so an entry older than a day is one no active branch is touching. keeping only a day cuts storage
#   roughly sevenfold against a week and bounds how long a poisoned or corrupt entry can survive to
#   the same day. the cost of expiring one too early is a single cold build, since a build cache is
#   reproducible by recompiling. raise only if pipelines on a branch left idle overnight start paying
#   cold builds often enough to matter
variable "runner_cache_retention_days" {
  type    = number
  default = 1
}
##[<] 🤖🤖
