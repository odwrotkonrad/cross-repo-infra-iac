##[>] 🤖🤖
provider "gitlab" {}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

provider "google" {
  project = var.gcp_project
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
#[why] the cluster this talks to is created by the same apply, so its endpoint and CA come from the
#   module's outputs rather than a kubeconfig on disk. the google client token authenticates as the
#   applier, so no cluster credential is stored anywhere
provider "helm" {
  kubernetes {
    host                   = module.ci_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.ci_cluster.cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

provider "kubernetes" {
  host                   = module.ci_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.ci_cluster.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

data "google_client_config" "default" {}
##[<] 🤖🤖
