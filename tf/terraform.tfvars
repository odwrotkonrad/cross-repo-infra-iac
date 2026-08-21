##[>] 🤖🤖
token_expires_at    = "2026-10-12"
manage_konradodwrot = true

tagging_projects = [
  "cross-repo/prose/assets",
  "cross-repo/prose/spec",
  "cross-repo/misc",
  "cross-repo/automation",
  "configs",
  "notes",
  "resume-md-pdf",
]

github_owner    = "odwrotkonrad"
local_runner_id = 53786471

CHE_PACKAGES_REF = "0.0.16"
##[>] 🤖🤖🤖
PROSE_ASSETS_REF = "v0.0.45"
PROSE_SPEC_REF   = "v0.0.11"
MISC_REF         = "v0.0.6"
##[<] 🤖🤖🤖

CI_IMAGES_REF = "v0.0.101"

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
      ai_sandbox = {
        name        = "ai-sandbox"
        path        = "ai-sandbox"
        description = "Local claude session sandbox: kind cluster plus per-session pods running the published config-baked sandbox image."
        topics      = ["sandbox", "kubernetes", "kind", "docker", "claude"]
      }
    }

    groups = {
      cross_repo = {
        name        = "cross-repo"
        path        = "cross-repo"
        description = "Shared, cross-repo material: automation, prose, CI scripts, infra."

        defaults = {
          public_jobs      = false
          protection_level = "maintainer"
          github_mirror    = true
        }

        projects = {
          automation = {
            name              = "automation"
            path              = "automation"
            description       = "Cross-repo automation: prose propagation, dependency graph, regen MRs, local sync."
            topics            = ["automation", "ci", "dependency-graph", "gitlab"]
            push_access_level = "maintainer"

            ci_pipeline_variables_role = "maintainer"
            job_token_allowlist = [
              "cross-repo/prose/assets",
              "cross-repo/prose/spec",
              "cross-repo/misc",
              "cross-repo/infra/oci-images",
              "che-packages",
            ]
          }
          misc = {
            name              = "misc"
            path              = "misc"
            description       = "Shared CI scripts and templates rendered into every workspace repo at a pinned version."
            topics            = ["ci", "scripts", "shared", "zsh"]
            push_access_level = "maintainer"
          }
        }

        groups = {
          prose = {
            name        = "prose"
            path        = "prose"
            description = "Workspace prose: rendered assets and the spec."

            projects = {
              assets = {
                name              = "assets"
                path              = "assets"
                description       = "Rendered prose: purpose docs, README sources, AI payloads, shared fragments, license, doc templates."
                topics            = ["prose", "documentation", "templates"]
                push_access_level = "maintainer"
              }
              spec = {
                name              = "spec"
                path              = "spec"
                description       = "Conventions with runnable examples and every repo's behavior specs."
                topics            = ["prose", "conventions", "specs"]
                push_access_level = "maintainer"
              }
            }
          }
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
  }
}
##[<] 🤖🤖
