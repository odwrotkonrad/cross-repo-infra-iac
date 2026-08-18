##[>] 🤖🤖
resource "google_secret_manager_secret" "gitlab_token" {
  project   = google_project_service.secretmanager.project
  secret_id = "sandbox-gitlab-group-token"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "gitlab_token" {
  secret      = google_secret_manager_secret.gitlab_token.id
  secret_data = gitlab_group_access_token.sandbox.token
}

resource "google_secret_manager_secret" "ssh_private_key" {
  project   = google_project_service.secretmanager.project
  secret_id = "sandbox-ssh-private-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssh_private_key" {
  secret      = google_secret_manager_secret.ssh_private_key.id
  secret_data = tls_private_key.sandbox.private_key_openssh
}

resource "google_secret_manager_secret" "ssh_signing_key" {
  project   = google_project_service.secretmanager.project
  secret_id = "sandbox-ssh-signing-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssh_signing_key" {
  secret      = google_secret_manager_secret.ssh_signing_key.id
  secret_data = tls_private_key.sandbox_signing.private_key_openssh
}

resource "google_secret_manager_secret" "ssh_access_key_pub" {
  project   = google_project_service.secretmanager.project
  secret_id = "sandbox-ssh-access-key-pub"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssh_access_key_pub" {
  secret      = google_secret_manager_secret.ssh_access_key_pub.id
  secret_data = "${trimspace(tls_private_key.sandbox.public_key_openssh)} ${var.ssh_key_comment}\n"
}

resource "google_secret_manager_secret" "ssh_signing_key_pub" {
  project   = google_project_service.secretmanager.project
  secret_id = "sandbox-ssh-signing-key-pub"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ssh_signing_key_pub" {
  secret      = google_secret_manager_secret.ssh_signing_key_pub.id
  secret_data = "${trimspace(tls_private_key.sandbox_signing.public_key_openssh)} ${var.ssh_key_comment}\n"
}

resource "google_project_iam_member" "secret_accessor" {
  project = google_project.auth.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.sandbox.email}"
}
##[<] 🤖🤖
