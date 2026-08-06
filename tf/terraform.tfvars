##[>] 🤖🤖
token_expires_at    = "2026-10-12"
manage_konradodwrot = true

github_owner    = "odwrotkonrad"
local_runner_id = 53786471

trees = {
  konradodwrot = {
    name        = "konradodwrot"
    path        = "konradodwrot"
    description = "Root group."

    defaults = {
      public_jobs      = true
      protection_level = "maintainer"
      github_mirror    = true
    }

    projects = {
      conventions = {
        name        = "conventions"
        path        = "conventions"
        description = "Canonical repo conventions: purpose docs, commenting, Makefile style."
        topics      = ["conventions", "documentation", "standards"]
      }
      configs = {
        name             = "configs"
        path             = "configs"
        allow_force_push = true
        description      = "Dotfiles extended into root OS space, loaded onto the host from one root/ tree by che: symlinked, copied (.ontoHost.cp), or rendered (*.ontoHost.tpl)."
        topics           = ["dotfiles", "configuration", "macos", "zsh", "che"]
      }
      notes = {
        name        = "notes"
        path        = "notes"
        description = "Shared space for user-agent cross-session collaboration: versioned markdown notes carrying context, decisions, plans, open threads across sessions and repos."
        visibility  = "public"
        topics      = ["notes", "collaboration", "agents"]
      }
      resume_md_pdf = {
        name        = "resume-md-pdf"
        path        = "resume-md-pdf"
        description = "Generates a single-page PDF resume from Markdown: md-to-pdf rendering, styled/plain sources, content-match validation."
        visibility  = "public"
        topics      = ["resume", "markdown", "pdf", "pdf-one-pager", "file-generation"]
      }
      go_modules = {
        name                = "go-modules"
        path                = "go-modules"
        description         = "Go monorepo: che (spec-driven dotfile loader, with the render engine and doc-rendering CLIs as its render/ package tree), get-os-open-files-with, get-term-open-files-with. Per-module go.mod and dir-prefixed release tags."
        topics              = ["go", "monorepo", "cli", "che"]
        pages_unique_domain = false
      }
      sandbox = {
        name        = "sandbox"
        path        = "sandbox"
        description = "Local claude session sandbox: kind cluster plus per-session pods running the published config-baked sandbox image."
        topics      = ["sandbox", "kubernetes", "kind", "docker", "claude"]
      }
    }

    groups = {
      infra = {
        name        = "infra"
        path        = "infra"
        description = "Infrastructure as code."

        defaults = {
          public_jobs      = false
          protection_level = "maintainer"
          github_mirror    = true
        }

        projects = {
          ci_images = {
            name                       = "oci-images"
            path                       = "oci-images"
            description                = "Shared OCI container images: multi-arch ci-linux CI base, dev-sandbox config-baked dev image."
            topics                     = ["ci", "docker", "container", "gitlab", "toolchain"]
            enable_local_runner        = true
            ci_pipeline_variables_role = "maintainer"
          }
          iac = {
            name        = "iac"
            path        = "iac"
            description = "The konradodwrot group tree and the sandbox identity it holds, as Terraform."
            topics      = ["terraform", "infrastructure", "gitlab", "gcp", "iac", "secrets"]
          }
        }
      }
    }
  }
}
##[<] 🤖🤖
