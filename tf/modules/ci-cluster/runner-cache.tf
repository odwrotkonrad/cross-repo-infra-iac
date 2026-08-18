##[>] 🤖🤖
resource "google_storage_bucket" "runner_cache" {
  project = google_project.ci.project_id
  name    = "${google_project.ci.project_id}-runner-cache"

  depends_on = [google_project_iam_member.ci_applier]

  location = var.region

  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  force_destroy = true

  versioning {
    enabled = false
  }

  soft_delete_policy {
    retention_duration_seconds = 0
  }

  lifecycle_rule {
    condition {
      age = var.runner_cache_retention_days
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 1
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_storage_bucket_iam_member" "runner_cache" {
  bucket = google_storage_bucket.runner_cache.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_service_account_iam_member" "runner_sign" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.runner.email}"
}
##[<] 🤖🤖
