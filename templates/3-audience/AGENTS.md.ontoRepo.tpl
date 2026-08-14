# infra

The `restricted` group and the sandbox identity it holds, as Terraform.

@assets/docs-agents/purpose.md

{{ remoteFile "gitlab.com/konradodwrot/conventions//conventions/conventions.md" }}

## Specs Before Implementation

Functionality added / modified / removed → edit `spec/` scenarios FIRST, then
implement, then set each touched `Status:`. New: `Status: todo`. Removed:
delete the scenario, same change. Never implement unspecced.

Vetting dirs bound edits: `spec/vetted/` never touch; `spec/vetted_title_only/`
titles frozen, rest editable; `spec/unvetted_ai/` free rein, all new AI
scenarios land here. Moving files and scenarios between dirs must come from
human will. `technical-requirements.md`
same dirs, prefer `vetted/`: on add/change urge the human to vet first.

@assets/data/makefile.agents.md

## Directory Tree

@assets/data/repo-structure.md
