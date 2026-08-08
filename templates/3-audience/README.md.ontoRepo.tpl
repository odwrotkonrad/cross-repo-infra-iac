# infra

The `restricted` group and the sandbox identity it holds, as Terraform.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Two concerns, one state

- **Group tree** — `tf/terraform.tfvars` + `tf/levels.tf` + `tf/modules/level`, the
  same `level` pattern as `infra/git-repos`, trimmed (no GitHub mirror, no local
  runner). The `restricted` root group is UI-created and imported (`parent_id =
  null`); Terraform owns its `infra` project and branch protection.
- **Identity/secrets** — `tf/gitlab-token.tf`, `tf/ssh-key.tf`,
  `tf/gcp-identity.tf`, `tf/secrets.tf`: the `konradodwrot` group token, the
  sandbox SSH key, the restricted GCP SA, and the two Secrets Manager secrets the
  sandbox reads.

Both share one state in the separate `konradodwrot/restricted-tfstate` GCS
bucket, isolated from git-repos at the storage boundary.

## State bucket bootstrap (one-time)

The state bucket must exist before `make init` — a bucket cannot hold the state
that creates it. Create it out-of-band, applied by your own identity:

```sh
gcloud storage buckets create gs://konradodwrot/restricted-tfstate \
  --project=main-493613 --location=EU --uniform-bucket-level-access
```

Lock its IAM to your identity (and the restricted CI identity if CI applies).

## First apply

```sh
make init                 # binds to konradodwrot/restricted-tfstate
# import the UI-created group and (if pre-created) the infra project:
terraform -chdir=tf import 'module.l0.gitlab_group.this["restricted"]' 203029
make validate && make plan && make apply
```

## Sandbox SA key into 1Password (terraform-managed)

`tf/modules/auth/sandbox/op.tf` writes the SA key JSON into the
`SandboxProgrammaticAccess` vault (item `sandbox-gcp-sa`, field `sa_key`) on
every apply, no manual `op item edit`. Prerequisites, one-time, manual:

- 1P vault `SandboxProgrammaticAccess`, your own write access kept.
- A 1P service account with write access to that vault only, its token passed
  as `TF_VAR_op_service_account_token`.
- A billing account id for the `konradodwrot-sandbox-auth` project, passed as
  `TF_VAR_gcp_billing_account`.
- Applies creating the GCP folder tree/project run locally with your own
  gcloud identity (org-level perms); the CI applier SA has none.
- The apt signing key, generated out-of-band (`gpg --quick-gen-key`, never by
  Terraform), stored as op item `apt-signing-gpg` in `SandboxProgrammaticAccess`:
  one section with fields labeled exactly `private_key` (armored secret key
  export) and `passphrase`. The passphrase must satisfy GitLab masking: at
  least 8 chars, no spaces, base64-safe charset.
- Two iac project CI variables (unprotected + masked), so MR-branch `plan`
  runs: `TF_VAR_op_service_account_token`, `TF_VAR_gcp_billing_account`.

## CI variables (masked + protected)

`tf/ci-variables.tf` creates two masked, protected group variables on the
`restricted` group for the CI applier: `TF_GITLAB_TOKEN` (the restricted CI's
own gitlab token, not the sandbox token) and `GOOGLE_CREDENTIALS` (base64 SA
key). Values come from sensitive inputs and enter the (storage-isolated)
restricted state. Populate them one of two ways:

- **TF-managed:** pass at apply — `TF_VAR_ci_gitlab_token=… TF_VAR_ci_google_credentials=… make apply`.
- **Manual:** leave the vars empty; Terraform creates the group variables empty, then set their values in the GitLab UI (still masked + protected).

Job logs are private on every restricted project (`public_jobs = false`), so
neither variable is ever exposed to a non-member.

## Token isolation

The `konradodwrot` group token has zero reach into `restricted` (separate root
group). Prove it: `GITLAB_TOKEN=<token> glab api groups/restricted` returns
403/404.

## License

[MIT](LICENSE)
