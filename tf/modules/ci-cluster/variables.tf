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

#[why] 4 vCPU / 16 GB fits two 1.5 vCPU / 6 GB job pods plus system overhead, so the ~0.5 vCPU and
#   ~1.5 GB the node reserves is paid once per two jobs instead of once per job
variable "ci_node_pools" {
  type = map(object({
    arch         = string
    machine_type = string
  }))
  default = {
    linux-amd64 = { arch = "amd64", machine_type = "e2-standard-4" }
    linux-arm64 = { arch = "arm64", machine_type = "c4a-standard-4" }
  }
}

#[why] 8 nodes x 2 pods = the runner's 16-job concurrency cap, per pool, so either architecture can
#   absorb a full burst alone. this is the hard spend ceiling: billing alerts arrive hours late
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

variable "runner_default_image" {
  type    = string
  default = "registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest"
}

#[why] 16 job pods across 8 nodes per pool at 2 pods each: the runner cap and the node cap agree
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
    medium = { cpu_request = "1500m", memory_request = "3Gi", memory_limit = "6Gi" }
    big    = { cpu_request = "3", memory_request = "6Gi", memory_limit = "12Gi" }
  }
}

#[why] the size a job gets when its tag names none
variable "job_default_size" {
  type    = string
  default = "medium"
}
##[<] 🤖🤖
