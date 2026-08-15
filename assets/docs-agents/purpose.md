# Purpose

## What It Is

Terraform for the separate top-level `restricted` group: the group tree, its `infra` project, branch protection, and the sandbox identity it holds. The identity: a GitLab `konradodwrot` group access token (Developer, write, no delete), a shared sandbox SSH key, a least-privileged GCP service account, and the Secrets Manager secrets they flow through. State sits in its own GCS bucket, apart from git-repos.

## Why It Exists

GitLab permission inheritance is additive-only: a write token on `konradodwrot` reaches every subgroup, no way to fence one off. A write token agents cannot reach must live, identity and all, outside the `konradodwrot` subtree. This repo is that outside group's source of truth, applied by your own identity, never by a sandbox.

## Goals

- One repo owns the whole `restricted` group tree and the sandbox identity.
- Sandbox identity is code: GitLab token, SSH key, GCP SA, Secrets Manager secrets.
- Least privilege: the GCP SA reads only its two secrets, the GitLab token is Developer (write, no delete) and cannot reach `restricted`.
- State isolated at the storage boundary: a separate GCS bucket from git-repos.
- Nothing secret committed: every sensitive value lives in Secrets Manager / op, every sensitive attr is masked.
