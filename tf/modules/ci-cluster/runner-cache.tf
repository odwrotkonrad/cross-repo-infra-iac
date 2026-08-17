##[>] 🤖🤖
#[why] the kubernetes executor gives every job a fresh pod and discards its disk, so a cache written
#   locally is unreadable by every later job: without this bucket the runner logs "No URL provided"
#   and every cache: block in every pipeline is dead weight, archiving files nothing can restore.
#   measured in go-modules: 202s per pipeline spent archiving 120k files no job could ever read,
#   while another job compiled the same 1422-package tree from cold
resource "google_storage_bucket" "runner_cache" {
  project = google_project.ci.project_id
  name    = "${google_project.ci.project_id}-runner-cache"

  #[why] nothing in this resource references the applier's storage.admin grant, so terraform is free
  #   to create both at once: the first apply did exactly that and died on 403 storage.buckets.create,
  #   the grant having landed 7s earlier but not yet propagated. this edge forces the grant first,
  #   and google_project_iam_member returning only after the binding is committed is what makes the
  #   ordering meaningful rather than merely cosmetic
  depends_on = [google_project_iam_member.ci_applier]

  #[why] single-region, same region as the cluster: cache traffic then stays in-region and is not
  #   billed as egress. multi-region would pay replication for data that is disposable by definition
  location = var.region

  #[why] STANDARD despite the short lifetime, not in spite of it: nearline and coldline bill a
  #   30 and 90 day minimum storage duration, charged in full even for an object deleted after
  #   var.runner_cache_retention_days. for data this short-lived they cost more, not less
  storage_class = "STANDARD"

  #[why] a build cache is not a distribution channel: uniform access removes per-object ACLs as a
  #   way to widen it, and public access prevention closes the bucket to the internet outright
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  #[why] the bucket is always non-empty, and every object in it is disposable: without this a
  #   destroy or a rename fails on "bucket not empty" and has to be emptied by hand first
  force_destroy = true

  #[why] cache contents are reproducible by recompiling, so a superseded entry has no recovery
  #   value: versioning here would bill for copies nobody would ever restore
  versioning {
    enabled = false
  }

  #[why] disabled, and this is the one that actually matters for the bill: GCS defaults soft delete
  #   to 7 days, billing every deleted or overwritten object as stored for those 7 days. this cache
  #   overwrites its keys on every pipeline, so the default would retain a week of superseded copies
  #   and make the 1-day lifecycle rule below almost meaningless. 0 opts out entirely
  soft_delete_policy {
    retention_duration_seconds = 0
  }

  #[why] the whole retention story. entries are rewritten every pipeline and never pruned by the
  #   jobs themselves, so without this the bucket grows forever. a short window also bounds how long
  #   a poisoned or corrupt entry can survive, since nothing here is trusted indefinitely
  lifecycle_rule {
    condition {
      age = var.runner_cache_retention_days
    }
    action {
      type = "Delete"
    }
  }

  #[why] belt and braces with versioning disabled: if it is ever turned on, noncurrent objects still
  #   expire promptly instead of accumulating silently
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 1
    }
    action {
      type = "Delete"
    }
  }

  #[why] a multipart upload that dies with its job pod leaves parts behind that no lifecycle age
  #   rule reaches: without this they are billed indefinitely
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

#[why] scoped to this bucket, not project-wide storage admin: the runner may read and write cache
#   objects and reach nothing else. objectAdmin rather than objectUser because the cache client
#   deletes and overwrites its own entries
resource "google_storage_bucket_iam_member" "runner_cache" {
  bucket = google_storage_bucket.runner_cache.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.runner.email}"
}

#[why] objectAdmin permits the transfer but not the signing. the cache client reaches GCS through
#   signed URLs, and an identity with no key file signs by calling signBlob on its own service
#   account, which is a grant on the account rather than on the bucket. without it every archive and
#   restore died on "unable to sign bytes: Permission 'iam.serviceAccounts.signBlob' denied" and the
#   cache was inert in every pipeline while looking correctly configured. self-binding is the
#   documented shape for a workload identity that signs its own URLs: scoped to this one account,
#   not the project, so it cannot sign for any other identity
resource "google_service_account_iam_member" "runner_sign" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.runner.email}"
}
##[<] 🤖🤖
