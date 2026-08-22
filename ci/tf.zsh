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

# [why] the SA key travels base64 (a GitLab variable holds one line), but the gcs backend takes raw
#   json or a path: decode to a temp file and point the google provider at it, as CI's .tf-creds does
if [[ -n ${GOOGLE_CREDENTIALS:-} && ${GOOGLE_CREDENTIALS:0:1} != "{" && ! -f ${GOOGLE_CREDENTIALS} ]] {
  # [why] an explicit XXXXXX template, not `-t <prefix>`: GNU mktemp rejects a bare prefix, so the
  #   macOS-only form fails in the linux CI image
  key=$(mktemp "${TMPDIR:-/tmp}/tf-sa-key.XXXXXX")
  trap 'rm -f $key' EXIT INT TERM
  print -rn -- "$GOOGLE_CREDENTIALS" | base64 -d > $key
  [[ -s $key ]] || { print -u2 "decoded SA key is empty — check GOOGLE_CREDENTIALS in .env"; exit 1 }
  export GOOGLE_APPLICATION_CREDENTIALS=$key
  unset GOOGLE_CREDENTIALS
}

cd "$ROOT/tf"

TF=${TF:-terraform}

if [[ $1 == validate ]] {
  $TF init -input=false -backend=false
} else {
  $TF init -input=false
}
$TF "$@"
##[<] 🤖🤖
