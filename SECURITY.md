# Security Policy

This policy is the org-wide default for every
[Lentago Labs](https://github.com/lentago) repository.

## Reporting a vulnerability

**Please do not open a public issue for security problems.** Instead, use
either channel:

- **GitHub private vulnerability reporting** (preferred): the repo's
  **Security** tab → **Report a vulnerability**.
- **Email:** chris@lentago.dev

You can expect an acknowledgment within **7 days**. These repos are operated
by one person as an infrastructure practice — there is no security team and no
bug bounty, but reports are read and acted on.

## What counts

Especially valuable reports for this fleet:

- **Leaked secrets** — credentials, tokens, private keys, or signed URLs that
  slipped into code, history, CI logs, or rendered artifacts.
- **CI/CD and supply-chain issues** — workflow injection, overly broad OIDC
  trust, artifact tampering in anything under `shared-workflows` or a repo's
  `.github/workflows/`.
- **Cloud misconfiguration** in the Terraform here (public buckets, open
  security groups, over-permissive IAM).

## Scope

Only the **default branch** of each active repository is supported. Archived
repositories are frozen historical artifacts and won't be patched — but a
leaked-secret report against one is still very welcome, since secrets get
rotated regardless of where they leaked.

## Disclosure

Fix first, then disclose: once a report is resolved, the fix lands as a normal
PR. Credit is given in the PR/release notes unless you ask otherwise.
