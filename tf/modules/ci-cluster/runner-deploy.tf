##[>] 🤖🤖
locals {
  helper_image_arch = {
    amd64 = "x86_64"
    arm64 = "arm64"
  }

  go_proxy_pre_build       = "_go_proxy=${local.go_proxy}\n${file("${path.module}/go-proxy-pre-build.sh")}"
  ar_docker_auth_pre_build = "_ar_host=${local.registry_host}\n${file("${path.module}/ar-docker-auth-pre-build.sh")}"
  pre_build                = "${local.go_proxy_pre_build}\n${local.ar_docker_auth_pre_build}"

  runner_globals = <<-TOML
    concurrent = ${var.runner_concurrent}
    check_interval = 3
    log_level = "${var.runner_log_level}"
  TOML

  node_tolerations = {
    amd64 = "          \"ci=true\" = \"NoSchedule\""
    arm64 = "          \"ci=true\" = \"NoSchedule\"\n          \"kubernetes.io/arch=arm64\" = \"NoSchedule\""
  }

  runner_entries = join("\n", [
    for key, v in local.runner_variants : <<-TOML
      [[runners]]
        name = "gke-${v.arch}-${v.size}"
        url = "${var.gitlab_url}"
        token = "${gitlab_user_runner.ci[key].token}"
        executor = "kubernetes"
        limit = ${var.job_sizes[v.size].limit}
        request_concurrency = 4
        pre_build_script = ${jsonencode(local.pre_build)}
        [runners.cache]
          Type = "gcs"
          Shared = true
          [runners.cache.gcs]
            BucketName = "${google_storage_bucket.runner_cache.name}"
        [runners.kubernetes]
          namespace = "${var.runner_namespace}"
          service_account = "${var.job_service_account}"
          image = "${local.ci_registry}/ci-linux:${var.ci_images_ref}"
          helper_image = "${local.gitlab_registry_proxy}/gitlab-org/gitlab-runner/gitlab-runner-helper:${local.helper_image_arch[v.arch]}-v${var.runner_helper_version}"
          privileged = true
          poll_timeout = ${var.runner_poll_timeout}
          pull_policy = ["if-not-present"]
          cpu_request = "${var.job_sizes[v.size].cpu_request}"
          memory_request = "${var.job_sizes[v.size].memory_request}"
          memory_limit = "${var.job_sizes[v.size].memory_limit}"
          helper_cpu_request = "50m"
          helper_memory_request = "64Mi"
        [[runners.kubernetes.volumes.empty_dir]]
          name = "docker-certs"
          mount_path = "/certs"
          mount_propagation = "None"
        [runners.kubernetes.node_selector]
          "ci-arch" = "${v.arch}"
        [runners.kubernetes.node_tolerations]
${local.node_tolerations[v.arch]}
    TOML
  ])
}

resource "kubernetes_namespace_v1" "runner" {
  metadata {
    name = var.runner_namespace
  }

  depends_on = [google_container_node_pool.manager]
}

resource "helm_release" "runner" {
  name      = "gitlab-runner"
  namespace = var.runner_namespace

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.runner_chart_version

  values = [yamlencode({
    gitlabUrl = var.gitlab_url

    image = {
      registry = local.registry_host
      image    = "${trimprefix(local.gitlab_registry_proxy, "${local.registry_host}/")}/gitlab-org/gitlab-runner"
    }

    concurrent    = var.runner_concurrent
    checkInterval = 3

    runners = {
      configOverride = "${local.runner_globals}\n${local.runner_entries}"
    }

    serviceAccount = {
      create = true
      name   = var.runner_service_account
      annotations = {
        "iam.gke.io/gcp-service-account" = google_service_account.runner.email
      }
    }

    resources = {
      requests = { cpu = "100m", memory = "128Mi" }
    }

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
    kubernetes_service_account_v1.ci_job,
    google_service_account_iam_member.ci_job_workload_identity,
  ]
}
##[<] 🤖🤖
