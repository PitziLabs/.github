# fleet-ops — PitziLabs repo settings as code

Tooling to keep repo settings consistent across the PitziLabs fleet. Settings
drift is the thing `~/repos/CLAUDE.md` worries about most, and GitHub splits the
problem across three mechanisms — no single one covers everything:

| Layer | Covers | Mechanism here |
|---|---|---|
| **Branch protection** | PR-required, squash-only, no force-push/deletion, required status checks | **per-repo rulesets** — created/verified by `fleet-apply.sh` (`repo-ruleset.json`). Each repo also adds its own required status checks. |
| **Merge-button + topics** | squash-only button, auto-merge, delete-branch, the `pitzilabs`+`claude` topic spine | **`fleet-apply.sh`** (rulesets can't set these) |
| **File skeleton** | README/CLAUDE/LICENSE/CI-wrapper starter files | **`PitziLabs/repo-template`** GitHub template (copies files, not settings) |

The lesson that motivated this: a **GitHub template repo copies files, not
settings**, so it can't enforce branch protection or merge options. And a
**ruleset** governs branch rules but not merge-button options or topics. You
need all three layers — and on this org's **Free plan**, branch protection is
per-repo (`fleet-apply.sh` makes that one command), because the cleaner
org-wide ruleset is a paid feature (see below).

## `fleet-apply.sh` — merge settings + topic spine

```bash
./fleet-apply.sh                 # read-only check of all non-archived org repos
./fleet-apply.sh --apply         # apply merge-button + spine-topic fixes fleet-wide
./fleet-apply.sh --repo NAME     # scope to one repo (e.g. a freshly created one)
```

Idempotent. Read-only by default; only `--apply` mutates. It enforces
squash-only + auto-merge + delete-branch-on-merge and the `pitzilabs`+`claude`
topic spine, **creates the per-repo `main` branch ruleset** (`repo-ruleset.json`)
if one is missing, and **warns** if any repo still carries the copy-pasted
`bash bootstrap scripts…` review prompt (the regression fixed in June 2026). It
does not touch signature topics or existing rulesets.

Bootstrapping a freshly created repo is therefore one command:

```bash
./fleet-apply.sh --apply --repo <new-repo-name>
```

## `repo-ruleset.json` — the per-repo branch ruleset

The minimal branch ruleset applied to each repo's default branch: PR-required
(0 approvals), squash-only merge, no force-push, no branch deletion. Repos layer
their own required status checks (Terraform Plan, HA check-config, book compile,
…) on top via separate rulesets — rulesets are additive.

## `org-ruleset.json` — PARKED (needs GitHub Team)

The cleaner approach would be one ruleset at the org targeting `~ALL` repos, so
new repos inherit branch protection with no per-repo step. **Org-level rulesets
require a paid GitHub Team org plan** (verified 2026-06-15: on the Free plan the
create call returns 403 *"Upgrade to GitHub Team"* — and note it's the *plan*,
not token scope, that gates it). This file is kept ready for if/when the org
upgrades:

```bash
gh auth refresh -h github.com -s admin:org          # scope (necessary but not sufficient)
gh api -X POST orgs/PitziLabs/rulesets --input fleet-ops/org-ruleset.json
```

Until then, `fleet-apply.sh` + `repo-ruleset.json` cover the same ground
per-repo.
