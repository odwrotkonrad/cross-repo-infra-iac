##[>] 🤖🤖
terraform {
  required_version = "~> 1.15"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
    gpg = {
      source  = "Olivr/gpg"
      version = "~> 0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }

  backend "gcs" {
    bucket = "konradodwrot-restricted-tfstate"
    prefix = "restricted-infra"
  }
}
##[<] 🤖🤖
