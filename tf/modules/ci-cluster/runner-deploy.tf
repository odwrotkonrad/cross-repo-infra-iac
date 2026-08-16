##[>] 🤖🤖
#[why] the chart reads the runner token from a k8s secret, so terraform writes the value it already
#   holds from gitlab_user_runner rather than the pod fetching it at boot
resource "kubernetes_secret_v1" "runner_token" {
  for_each = var.ci_node_pools

  metadata {
    name      = "gitlab-runner-${each.value.arch}-token"
    namespace = var.runner_namespace
  }

  data = {
    runner-token = gitlab_user_runner.ci[each.key].token
  }

  depends_on = [kubernetes_namespace_v1.runner]
}

resource "kubernetes_namespace_v1" "runner" {
  metadata {
    name = var.runner_namespace
  }

  depends_on = [google_container_node_pool.manager]
}

#[why] one release per architecture: each runs its own manager pod bound to one runner token and one
#   node pool, so an arm64 job can never be picked up and then scheduled onto amd64 capacity
resource "helm_release" "runner" {
  for_each = var.ci_node_pools

  name      = "gitlab-runner-${each.value.arch}"
  namespace = var.runner_namespace

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.runner_chart_version

  values = [yamlencode({
    gitlabUrl = var.gitlab_url

    #[why] 16 concurrent jobs is the burst ceiling. the cluster autoscaler adds nodes only for pods
    #   this creates, so pod count follows queue depth and node count follows pod count
    concurrent    = var.runner_concurrent
    checkInterval = 3

    #[why] job pods request memory matching the SaaS default they replace, with CPU traded down for
    #   cost. node_selector pins each job to its architecture's pool; the toleration is what lets it
    #   onto the tainted CI nodes at all
    runners = {
      secret = kubernetes_secret_v1.runner_token[each.key].metadata[0].name
      config = <<-TOML
        [[runners]]
          [runners.kubernetes]
            namespace = "${var.runner_namespace}"
            image = "${var.runner_default_image}"
            privileged = true
            cpu_request = "${var.job_cpu_request}"
            memory_request = "${var.job_memory_request}"
            helper_cpu_request = "100m"
            helper_memory_request = "128Mi"
            [runners.kubernetes.node_selector]
              "ci-arch" = "${each.value.arch}"
            [runners.kubernetes.node_tolerations]
              "ci=true" = "NoSchedule"
      TOML
    }

    #[why] workload identity: the pod's k8s service account impersonates the GCP SA, so no key file
    serviceAccount = {
      create = true
      name   = var.runner_service_account
      annotations = {
        "iam.gke.io/gcp-service-account" = google_service_account.runner.email
      }
    }

    #[why] the manager dispatches work, it does not run builds, so it stays small
    resources = {
      requests = { cpu = "100m", memory = "128Mi" }
      limits   = { cpu = "500m", memory = "512Mi" }
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
    google_container_node_pool.manager,
    google_service_account_iam_member.runner_workload_identity,
  ]
}
##[<] 🤖🤖
