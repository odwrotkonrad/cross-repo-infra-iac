#!/usr/bin/env zsh
##[>] 🤖🤖
emulate -LR zsh
setopt errexit pipefail

ROOT=${0:a:h:h}
out=${1:-automation-event.env}
TF=${TF:-terraform}

variables=$($TF -chdir=$ROOT/tf show -json plan.tfplan | yq -p=json -o=json -I=0 '
  [.resource_changes // [] | .[]
    | select(.type == "gitlab_group_variable")
    | select(.change.actions | (contains(["create"]) or contains(["update"])))
    | select(.change.after.masked == false)
    | {"key": .change.after.key, "from": .change.before.value, "to": .change.after.value}]')

{
  print 'EVENT_TYPE=ci-var.changed'
  print -r -- "EVENT_DETAILS={\"variables\":$variables}"
} > $out
print -r -- "wrote $out: $variables"
##[<] 🤖🤖
