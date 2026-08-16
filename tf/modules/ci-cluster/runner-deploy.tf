##[>] 🤖🤖
#[why] one [[runners]] entry per architecture and size, all served by one manager. tokens come from
#   terraform, so this replaces the chart's registration step entirely: the chart rejects more than
#   one [[runners]] on the registration path, but accepts a complete config here. requests are the
#   scheduling reservation, limits the hard ceiling, both declared per size so no unit arithmetic can
#   silently corrupt a quantity. node_selector pins an entry to its pool, and the toleration is what
#   admits the job pod onto tainted CI nodes at all.
#
#   the /certs empty_dir is what makes docker:dind work: dind generates its TLS certs into
#   DOCKER_TLS_CERTDIR and the build container reads them back. under the docker executor they share
#   a volume implicitly, but k8s job containers share nothing unless declared, so without this every
#   dind job dies on "open /certs/client/ca.pem: no such file or directory"
locals {
  #[why] configOverride is written verbatim as config.toml, so the globals must live in it: values set
  #   elsewhere in the chart are ignored on this path. concurrent caps job pods across every entry, and
  #   request_concurrency stops six runners long-polling one request at a time
  runner_globals = <<-TOML
    concurrent = ${var.runner_concurrent}
    check_interval = 3
  TOML

  runner_entries = join("\n", [
    for key, v in local.runner_variants : <<-TOML
      [[runners]]
        name = "gke-${v.arch}-${v.size}"
        url = "${var.gitlab_url}"
        token = "${gitlab_user_runner.ci[key].token}"
        executor = "kubernetes"
        request_concurrency = 4
        #[why] declared before [runners.kubernetes]: these are sibling tables under [[runners]], and
        #   in TOML every key after a table header belongs to that table until the next one. placed
        #   after, [runners.cache] would read as a child of the kubernetes config and be ignored.
        #   Shared makes one cache serve every runner entry, so a job cached by the amd64 medium
        #   runner is restorable by any other, which is what lets sibling jobs and later pipelines
        #   hit the same keys. no credentials here on purpose: omitting them is what makes the
        #   client fall back to the ambient Workload Identity token, keeping the cluster key-free
        [runners.cache]
          Type = "gcs"
          Shared = true
          [runners.cache.gcs]
            BucketName = "${google_storage_bucket.runner_cache.name}"
        [runners.kubernetes]
          namespace = "${var.runner_namespace}"
          image = "${var.runner_default_image}"
          privileged = true
          cpu_request = "${var.job_sizes[v.size].cpu_request}"
          memory_request = "${var.job_sizes[v.size].memory_request}"
          memory_limit = "${var.job_sizes[v.size].memory_limit}"
          helper_cpu_request = "50m"
          helper_memory_request = "64Mi"
        [[runners.kubernetes.volumes.empty_dir]]
          name = "docker-certs"
          mount_path = "/certs"
        [runners.kubernetes.node_selector]
          "ci-arch" = "${v.arch}"
        [runners.kubernetes.node_tolerations]
          "ci=true" = "NoSchedule"
    TOML
  ])
}

resource "kubernetes_namespace_v1" "runner" {
  metadata {
    name = var.runner_namespace
  }

  depends_on = [google_container_node_pool.manager]
}

#[why] one manager deployment for every architecture and size: the runner binary serves many
#   [[runners]] entries from one process, so a new size or architecture is an entry, not another pod
#   to run and pay for
resource "helm_release" "runner" {
  name      = "gitlab-runner"
  namespace = var.runner_namespace

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.runner_chart_version

  values = [yamlencode({
    gitlabUrl = var.gitlab_url

    #[why] the cluster autoscaler adds nodes only for pods this manager creates, so pod count follows
    #   queue depth and node count follows pod count. this is the burst ceiling across all entries
    concurrent    = var.runner_concurrent
    checkInterval = 3

    #[why] configOverride, not config: the chart writes `config` to config.template.toml and feeds it
    #   to `gitlab-runner register`, which rejects more than one [[runners]] entry. configOverride is
    #   written verbatim as config.toml and skips registration entirely, which is what serving six
    #   entries from one manager requires
    runners = {
      configOverride = "${local.runner_globals}\n${local.runner_entries}"
    }

    #[why] workload identity: the pod's k8s service account impersonates the GCP SA, so no key file
    serviceAccount = {
      create = true
      name   = var.runner_service_account
      annotations = {
        "iam.gke.io/gcp-service-account" = google_service_account.runner.email
      }
    }

    #[why] a request but no limit: the manager is the one pod that must never be throttled or killed,
    #   since losing it stops every job being dispatched. it has its own node, so there is nothing to
    #   protect the node from and nothing to share with
    resources = {
      requests = { cpu = "100m", memory = "128Mi" }
    }

    #[why] pinned to the on-demand manager pool: it must survive preemption of every CI node and
    #   still be running when both CI pools sit at zero
    nodeSelector = {
      "cloud.google.com/gke-nodepool" = google_container_node_pool.manager.name
    }

    rbac = {
      create = true
    }
  })]

  depends_on = [
    kubernetes_namespace_v1.runner,
    google_service_account_iam_member.runner_workload_identity,
  ]
}
##[<] 🤖🤖
