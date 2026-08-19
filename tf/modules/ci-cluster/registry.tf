##[>] 🤖🤖
#[what] every image the cluster pulls, served from this project over private google access
#[why] job pods failed `prepare environment` pulling the runner helper: containerd answers the
#   registry's 401 by fetching a token from gitlab.com/jwt/auth, and that connect timed out
#   against public cloudflare space. the token fetch is anonymous, so no credential fixes it.
#   pulling from here removes the public hop entirely
locals {
  registry_host = "${var.region}-docker.pkg.dev"

  ci_registry              = "${local.registry_host}/${google_project.ci.project_id}/${google_artifact_registry_repository.ci.repository_id}"
  gitlab_registry_proxy    = "${local.registry_host}/${google_project.ci.project_id}/${google_artifact_registry_repository.remote_gitlab.repository_id}"
  dockerhub_registry_proxy = "${local.registry_host}/${google_project.ci.project_id}/${google_artifact_registry_repository.remote_dockerhub.repository_id}"
}

#[what] our own images, pushed by infra/oci-images, plus the buildx layer cache beside them
#[why] a remote repository fronting where we pushed would send a build result out to a public
#   registry and back to be read by the cluster that produced it
resource "google_artifact_registry_repository" "ci" {
  project       = google_project_service.artifactregistry.project
  location      = var.region
  repository_id = "ci"
  description   = "images built by infra/oci-images, and their buildx layer cache"
  format        = "DOCKER"

  #[why] `mode=max` cache is disposable and rewritten every build, so it is deleted on age while
  #   version tags are kept. matching the cache bucket's reasoning, not the images'
  cleanup_policies {
    id     = "expire-buildx-cache"
    action = "DELETE"

    condition {
      tag_state             = "ANY"
      package_name_prefixes = ["ci-linux-cache", "ci-linux-dind-cache"]
      older_than            = "${var.registry_cache_retention_days * 24}h"
    }
  }

  depends_on = [google_project_iam_member.ci_applier]
}

#[why] anonymous upstream: a token request carrying no credentials returns one that reads the
#   manifest, for the runner helper on both arches and for anything public in the group. so no
#   upstream_credentials block, and nothing to rotate
resource "google_artifact_registry_repository" "remote_gitlab" {
  project       = google_project_service.artifactregistry.project
  location      = var.region
  repository_id = "remote-gitlab"
  description   = "pull-through cache for registry.gitlab.com"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "registry.gitlab.com"

    docker_repository {
      custom_repository {
        uri = "https://registry.gitlab.com"
      }
    }
  }

  depends_on = [google_project_iam_member.ci_applier]
}

resource "google_artifact_registry_repository" "remote_dockerhub" {
  project       = google_project_service.artifactregistry.project
  location      = var.region
  repository_id = "remote-dockerhub"
  description   = "pull-through cache for docker hub"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "docker hub"

    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }

  depends_on = [google_project_iam_member.ci_applier]
}

#[why] the kubelet pulls with the node identity, so reader here is what makes every job image
#   pullable. granted per-repository rather than project-wide: a privileged container reaching
#   the metadata server gets an identity that can fetch images and still cannot publish one
resource "google_artifact_registry_repository_iam_member" "node_reader" {
  for_each = {
    ci               = google_artifact_registry_repository.ci.name
    remote-gitlab    = google_artifact_registry_repository.remote_gitlab.name
    remote-dockerhub = google_artifact_registry_repository.remote_dockerhub.name
  }

  project    = google_project.ci.project_id
  location   = var.region
  repository = each.value
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.node.email}"
}
##[<] 🤖🤖
