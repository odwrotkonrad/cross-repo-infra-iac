##[>] 🤖🤖
#[why] every job pod pulls the runner helper before its script runs, and job pods declare a cpu
#   request but no limit, so a node's cpu sits overcommitted while builds run. a pull starting into
#   that contention can miss its deadline and fail the job in prepare_script with what reads as a
#   network timeout ("dial tcp ...:443: i/o timeout") though the network is fine: the same node
#   completes the pull in seconds when idle. this daemonset pulls the image once per node, at node
#   join, so the job's pull is a cache hit and never races the jobs already running beside it.
#
#[why] a sleeping pause container, not a job: the pod must stay resident, since a completed pod's
#   images are eligible for kubelet garbage collection. holding the image as a running container's
#   own image is what keeps it pinned on the node
locals {
  #[why] the helper tag is per architecture and pinned to the runner version the chart deploys, so a
  #   chart bump moves both. amd64 uses gitlab's x86_64 spelling, not the k8s one
  helper_image_arch = {
    amd64 = "x86_64"
    arm64 = "arm64"
  }
}

#[why] below zero, so every ordinary pod outranks these: the scheduler preempts the prepull pod for a
#   job pod rather than leaving the job pending on a full node
resource "kubernetes_priority_class_v1" "prepull" {
  metadata {
    name = "image-prepull"
  }

  value       = -10
  description = "cache-warming pods, preemptible by any real workload"
}

resource "kubernetes_daemon_set_v1" "image_prepull" {
  for_each = var.ci_node_pools

  metadata {
    name      = "image-prepull-${each.value.arch}"
    namespace = var.runner_namespace
  }

  spec {
    selector {
      match_labels = {
        app  = "image-prepull"
        arch = each.value.arch
      }
    }

    template {
      metadata {
        labels = {
          app  = "image-prepull"
          arch = each.value.arch
        }
      }

      spec {
        #[why] the pull is the point: this container never runs the helper, it only holds it resident
        container {
          name    = "helper"
          image   = "registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${local.helper_image_arch[each.value.arch]}-v${var.runner_helper_version}"
          command = ["sleep", "infinity"]

          #[why] the smallest reservation that still schedules: this pod must never be what stops a
          #   job pod fitting on a node it shares
          resources {
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
            limits = {
              memory = "32Mi"
            }
          }
        }

        #[why] the same nodeSelector and tolerations the job pods use, so this lands on exactly the
        #   nodes whose cache it is meant to warm and nowhere else
        node_selector = {
          "ci-arch" = each.value.arch
        }

        toleration {
          key      = "ci"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }

        dynamic "toleration" {
          for_each = each.value.arch == "arm64" ? [1] : []

          content {
            key      = "kubernetes.io/arch"
            operator = "Equal"
            value    = "arm64"
            effect   = "NoSchedule"
          }
        }

        #[why] negative priority, so a job pod waiting on capacity preempts this one: warming a cache
        #   is worth less than running the job the cache exists for. the image stays on the node after
        #   eviction, which is the whole point
        priority_class_name = kubernetes_priority_class_v1.prepull.metadata[0].name
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.runner]
}
##[<] 🤖🤖
