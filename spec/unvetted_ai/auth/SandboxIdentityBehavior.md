<!--[>] 🤖🤖 -->
Feature: Sandbox identity provisioned by the auth module

Scenario: an agent session pushes work and opens MRs without holding a destructive credential
  Status: todo
  Given the applied auth module minted the `sandbox-rw-nodelete` group access token (developer, api + read_repository + write_repository) on `konradodwrot`
  When a sandbox pod authenticates gitlab with that token
  Then it pushes to non-protected branches and creates MRs in any `konradodwrot` project
  And pushes to protected branches are rejected
  And branch, tag, and repository deletion beyond developer rights is rejected

Scenario: the sandbox reads every identity secret through one project-scoped grant
  Status: todo
  Given the five sandbox secrets live in the `konradodwrot-sandbox-auth` project
  And the sandbox SA holds `roles/secretmanager.secretAccessor` on that project, with no per-secret IAM members
  When the pod fetches any of the five secrets via ADC
  Then every fetch succeeds with that single grant
  And the SA reads no secret outside the auth project

Scenario: the sandbox sees the dev management plane read-only until dev access is designed
  Status: todo
  Given the sandbox SA holds `roles/viewer` on the `dev` folder under the `sandbox` folder
  When the pod queries resources under the `dev` folder
  Then reads succeed and writes are denied

Scenario: a compromised sandbox yields no 1Password access
  Status: todo
  Given terraform provisions no op identity for the sandbox
  When a pod is inspected for op credentials
  Then no op token, account, or vault access exists inside the pod

Scenario: a key rotation lands in 1Password with no manual step
  Status: todo
  Given the auth module owns the SA key and the `sandbox-gcp-sa` item in the `SandboxProgrammaticAccess` vault
  When an apply creates or rotates the SA key
  Then the vault item's `sa_key` field carries the fresh key JSON without any `op item edit`

Scenario: the host keeps its own access while the sandbox stays credential-minimal
  Status: todo
  Given the user retains write access to the `SandboxProgrammaticAccess` vault
  And the auth module provisions no github credential
  When the host injects identity into a session
  Then only the SA key read from the vault crosses into the pod
  And github operations from the sandbox run as anonymous read
<!--[<] 🤖🤖 -->
