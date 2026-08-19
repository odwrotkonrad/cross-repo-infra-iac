##[>] 🤖🤖
token_expires_at    = "2026-10-12"
manage_konradodwrot = true

#[why] prose already minted through its own token; the rest gain tags so their che includes and
#   template refs can be pinned to a version instead of tracking main
tagging_projects = ["prose", "configs", "control", "notes", "resume-md-pdf"]

github_owner    = "odwrotkonrad"
local_runner_id = 53786471

#[why] the catalog version every repo's CI pins to, published as the CHE_PACKAGES_REF group
#   variable. Declared here rather than in a consumer's tree: a pin inside che/ matched
#   release-che's `changes:` rule and cut a che release for a catalog-only change. control's
#   fan-out raises this line when che-packages publishes
che_packages_ref = "0.0.16"

ci_images_ref = "latest"

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
      prose = {
        name              = "prose"
        path              = "prose"
        description       = "Centralized prose: conventions, purpose docs, README sources, specs, shared doc templates."
        topics            = ["prose", "documentation", "conventions", "specs", "templates"]
        push_access_level = "maintainer"
      }
      control = {
        name              = "control"
        path              = "control"
        description       = "Cross-repo automation: prose propagation, dependency graph, regen MRs, local sync."
        topics            = ["automation", "ci", "dependency-graph", "gitlab"]
        push_access_level = "maintainer"

        ci_pipeline_variables_role = "maintainer"
        job_token_allowlist        = ["prose"]
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
        visibility  = "private"
        topics      = ["notes", "collaboration", "agents"]
      }
      resume_md_pdf = {
        name        = "resume-md-pdf"
        path        = "resume-md-pdf"
        description = "Generates a single-page PDF resume from Markdown: md-to-pdf rendering, styled/plain sources, content-match validation."
        visibility  = "public"
        topics      = ["resume", "markdown", "pdf", "pdf-one-pager", "file-generation"]
      }
      homebrew_tap = {
        name              = "homebrew-tap"
        path              = "homebrew-tap"
        description       = "Homebrew tap: Formula/che.rb, committed by the go-modules release pipeline via the commits API."
        topics            = ["homebrew", "tap", "brew", "che"]
        push_access_level = "maintainer"
      }
      go_modules = {
        name                = "go-modules"
        path                = "go-modules"
        description         = "Go monorepo: che (spec-driven dotfile loader, with the render engine as its render/ package tree, exposed as che render subcommands), get-os-open-files-with, get-term-open-files-with. Per-module go.mod and dir-prefixed release tags."
        topics              = ["go", "monorepo", "cli", "che"]
        pages_unique_domain = false
      }
      che_packages = {
        name        = "che-packages"
        path        = "che-packages"
        description = "che's package catalog: packages.yml plus install scripts, published as a versioned definitions tarball. Every package's every install method proven by a pytest suite in containers."
        topics      = ["packages", "che", "catalog", "pytest", "installers"]
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
          sandbox = {
            name        = "sandbox"
            path        = "sandbox"
            description = "Local claude session sandbox: kind cluster plus per-session pods running the published config-baked sandbox image."
            topics      = ["sandbox", "kubernetes", "kind", "docker", "claude"]
          }
          iac = {
            name                 = "iac"
            path                 = "iac"
            description          = "The konradodwrot group tree and the identities it holds, as Terraform."
            topics               = ["terraform", "infrastructure", "gitlab", "gcp", "iac", "secrets"]
            protect_all_branches = true
          }
        }
      }
    }
  }
}
##[<] 🤖🤖
