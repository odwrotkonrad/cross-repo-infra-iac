##[>] 🤖🤖
#[what] Project's Makefile
SHELL := zsh
.SHELLFLAGS := -c
TF ?= terraform

WRAPPERS := repo-prepare-dev-env 
COMMANDS := render-templates repo-render-env repo-prepare-deps repo-ci-prepare-hooks repo-ci-precommit-all init fmt validate lock plan apply semver-next tag-mint

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Dev Environment [genai-include]
#[why] render precedes hooks: the docsgen pre-commit hook runs render-templates and fails on drift,
#   so a fresh clone whose generated files were never rendered would fail its first commit
#[what] make a fresh clone a working checkout: generated docs, dependencies, git hooks
repo-prepare-dev-env: repo-render-env render-templates repo-prepare-deps repo-ci-prepare-hooks

#[why] the repo declares terraform in its devEnv profile, so no host or image has to carry it in advance
#[what] install this repo's toolchain, then initialise the backend and providers
#[why] providers only, never `init` proper: initialising the backend dials the GCS state bucket and
#   needs credentials no fresh checkout or image build has. preparing an environment installs tools,
#   it does not reach for state
repo-prepare-deps:
	@che run --profiles=devEnv
	@cd tf && terraform init -input=false -backend=false >/dev/null
##[<] Dev Environment

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md, repo-structure.md, CLAUDE.md, AGENTS.md, README.md)
render-templates:
	@che render-templates --profiles=ontoRepo

#[what] render .env.tpl to .env: upstream refs and CI variables via glab, secrets via op
repo-render-env:
	@CHE_ENV_UNSET=empty che render-templates --profiles=envSeed
##[<] Docs

##[>] CI [genai-include]
#[what] install lefthook git hooks
repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
repo-ci-precommit-all: repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force
##[<] CI

##[>] Release [genai-include]
#[what] print the next semver tag inferred from the last tag..HEAD diff (override: `semver: major|minor|patch` commit token)
semver-next: render-templates
	@shared/ci/semver-bump.zsh

#[what] mint and push the next semver tag (CI: authed via TAG_TOKEN)
tag-mint: render-templates
	@shared/ci/tag-mint.zsh
##[<] Release

##[>] Terraform [genai-include]
#[what] init the backend and providers
init:
	@ci/tf.zsh version

#[what] format all terraform files in place
fmt:
	$(TF) -chdir=tf fmt -recursive

#[what] check formatting and validate the config
validate:
	$(TF) -chdir=tf fmt -check -recursive
	@ci/tf.zsh validate

#[what] regenerate the provider lock with hashes for all CI + dev platforms
lock:
	$(TF) -chdir=tf providers lock -platform=linux_amd64 -platform=linux_arm64 -platform=darwin_arm64 -platform=darwin_amd64

#[what] show the plan (writes tf/plan.tfplan for CI)
plan:
	@ci/tf.zsh plan -input=false -out=plan.tfplan

#[what] apply the saved plan (plan.tfplan)
apply:
	@ci/tf.zsh apply -input=false plan.tfplan
##[<] Terraform
##[<] 🤖🤖
