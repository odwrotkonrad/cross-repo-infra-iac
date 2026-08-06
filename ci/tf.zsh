#!/usr/bin/env zsh
##[>] 🤖🤖
# Run terraform: init the backend once (idempotent), then the passed
# subcommand. Args: $@ terraform subcommand + flags (e.g. plan, apply).
#
# Secrets: locally, source the rendered .env (GITLAB_TOKEN, op-resolved at
# render time) when the var is not already set. In CI, GITLAB_TOKEN comes
# from a masked variable, so .env is absent and this is a no-op.
emulate -LR zsh
setopt errexit pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

if [[ -z ${GITLAB_TOKEN:-} && -f "$ROOT/.env" ]] {
  set -a
  source "$ROOT/.env"
  set +a
}

cd "$ROOT/tf"

TF=${TF:-terraform}

#[why] validate needs no state: init without the GCS backend, so credential-less MR pipelines can run it
if [[ $1 == validate ]] {
  $TF init -input=false -backend=false
} else {
  $TF init -input=false
}
$TF "$@"
##[<] 🤖🤖
