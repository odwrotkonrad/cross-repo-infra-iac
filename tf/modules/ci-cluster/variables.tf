##[>] 🤖🤖
variable "project_id" {
  type = string
}

variable "dev_folder_name" {
  type = string
}

variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

variable "gitlab_group_id" {
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

#[why] dind is disk-bound more than CPU-bound, and pd-balanced IOPS scale with size
variable "ci_disk_size_gb" {
  type    = number
  default = 100
}

variable "manager_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "runner_namespace" {
  type    = string
  default = "gitlab-runner"
}

variable "runner_service_account" {
  type    = string
  default = "gitlab-runner"
}

variable "gitlab_url" {
  type    = string
  default = "https://gitlab.com/"
}

variable "runner_chart_version" {
  type    = string
  default = "0.71.0"
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

#[why] memory matches the SaaS default this replaces (8 GB tier); CPU is traded down for cost.
#   two of these fit a 4 vCPU / 16 GB node with room for kubelet and system daemons
variable "job_cpu_request" {
  type    = string
  default = "1500m"
}

variable "job_memory_request" {
  type    = string
  default = "6Gi"
}
##[<] 🤖🤖
