# PitziLabs Language Census

A periodic census of the programming/markup/config languages represented across
the **PitziLabs org repositories**, ordered by prominence (lines of code). This
file is meant to be **regenerated periodically** — see
[Regenerating](#regenerating) for the exact, reproducible command, and log each
refresh in the [Update log](#update-log).

> **Scope.** Only repositories whose `origin` remote is under
> `github.com/PitziLabs/`. Measured over the maintainer's `~/repos` working tree,
> so it counts what's checked out locally for each org repo (not a GitHub API
> query). Third-party clones (`ProxmoxMCP`, `firewalla-mcp`, `firewalla-tools`)
> and personal repos (`professional-endeavors`, `prompts`) are **excluded**, as
> are local-only scratch dirs that aren't git repos. Generated artifacts and
> vendored dependencies are excluded (see [Methodology](#methodology)); `cloc`
> additionally **deduplicates byte-identical files**, so the deliberately-mirrored
> `CLAUDE.md` / PR-workflow text is counted once, not once per repo.
>
> **Repos in scope (14):** `bullpen`, `.github`, `firewalla-axiom-pipeline`,
> `foundry-platform-demo`, `homeassistant-config`, `homelab-observability`,
> `ice-cream-book`, `music-curator`, `office-presence`, `pitzilabs-dev`,
> `reference-checker`, `repo-template`, `shared-workflows`, `workstation-bootstrap`.

---

## Last updated: 2026-06-17

**Headline:** across the org repos, **data and docs lead** — JSON (registry dumps,
dashboards, config) is ~38% and Markdown ~24%. The executing spine is Shell, then
the JavaScript/JSX/Astro web stack, then Terraform; Python is small here (most of
the fleet's Python lived in third-party clones, now out of scope).

### By lines of code

Tool: `cloc 2.06`. Total: **76,388 lines of code** across **519 unique files**.

| # | Language | Code | Comment | Blank | Files | Share of code |
|---|----------|-----:|--------:|------:|------:|--------------:|
| 1 | JSON | 29,004 | 0 | 0 | 36 | 38.0% |
| 2 | Markdown | 18,324 | 40 | 9,112 | 187 | 24.0% |
| 3 | Shell (Bourne + Bash) | 8,258 | 2,347 | 1,529 | 61 | 10.8% |
| 4 | YAML | 6,724 | 1,075 | 506 | 91 | 8.8% |
| 5 | JSX (React) | 3,627 | 301 | 253 | 29 | 4.7% |
| 6 | HCL / Terraform | 3,530 | 946 | 743 | 69 | 4.6% |
| 7 | JavaScript | 2,324 | 253 | 269 | 6 | 3.0% |
| 8 | Astro | 1,737 | 98 | 245 | 15 | 2.3% |
| 9 | Python | 1,218 | 177 | 326 | 7 | 1.6% |
| 10 | HTML | 1,206 | 12 | 108 | 9 | 1.6% |
| 11 | CSS | 314 | 33 | 20 | 3 | 0.4% |
| 12 | TypeScript | 56 | 9 | 5 | 3 | 0.07% |
| 13 | TOML | 14 | 5 | 3 | 1 | 0.02% |
| 14 | Dockerfile | 4 | 10 | 4 | 1 | ~0% |

(`cloc` also reported 48 lines of plain "Text" — omitted as not a language. It
splits Shell into "Bourne Shell" 7,174 + "Bourne Again Shell" 1,084; folded above.)

### Programming / scripting languages only

Stripping docs (Markdown), data (JSON), config (YAML/TOML), and markup (HTML/CSS),
the code that actually executes ranks:

| # | Language | Code |
|---|----------|-----:|
| 1 | Shell / Bash | 8,258 |
| 2 | JavaScript family (JS + JSX) | 5,951 |
| 3 | Terraform / HCL *(infra-as-code)* | 3,530 |
| 4 | Astro | 1,737 |
| 5 | Python | 1,218 |
| 6 | TypeScript | 56 |

### Notes

- **JSON leads but carries no logic** — it's HA entity/device/dashboard registry
  snapshots (`homeassistant-config`), Grafana dashboard JSON
  (`homelab-observability`), and `package.json`-style config. Discount it as data
  and the picture is Markdown docs over a Shell → JS/Astro → Terraform code base.
- **Shell is the most-commented code in the fleet** — 2,347 comment lines against
  8,258 of code (~28%), consistent with ops/gitops scripts written to be audited.
- **Python is small in-org.** The fleet's heavier Python (`ProxmoxMCP`,
  `firewalla-mcp`) lives in third-party clones that are out of scope; what remains
  is mostly `reference-checker` and small helpers.

---

## Methodology

Membership rule: a repo is in scope iff its `origin` remote matches
`github.com/PitziLabs/`. Run from the fleet root (`~/repos`) with `cloc`.
Exclusions, and why:

- **VCS / dependencies / build output:** `.git`, `node_modules`, `.venv`, `venv`,
  `__pycache__`, `dist`, `build`, `.next`, `vendor`, `target`, `.terraform`,
  `.astro` (build cache), and `package-lock.json` (generated lockfile).
- **Generated artifacts:** `*/wiki-site/site/*` (MkDocs-rendered HTML) and
  `*/.playwright-mcp/*` (Playwright accessibility snapshots) — both belong to
  out-of-scope personal repos now, but the excludes are kept for safety.
- **Binary / asset extensions:** `docx, png, pdf, woff2, psd, jpeg, jpg, gz, svg, map`.

`cloc`'s default skipping of byte-identical duplicate files is kept on purpose —
that's what dedups the mirrored `CLAUDE.md` / PR-workflow text.

### Regenerating

```bash
cd ~/repos

# Derive the in-scope repo list from actual remotes (don't hand-maintain it):
ORG_REPOS=$(for d in */; do d="${d%/}"; \
  git -C "$d" remote get-url origin 2>/dev/null \
    | grep -q 'github.com[:/]PitziLabs/' && printf '%s ' "$d"; done)

cloc $ORG_REPOS \
  --quiet \
  --exclude-dir=.git,node_modules,.venv,venv,__pycache__,dist,build,.next,vendor,target,.terraform,.astro,.playwright-mcp,site \
  --not-match-d='wiki-site/site' \
  --fullpath --not-match-f='package-lock\.json' \
  --exclude-ext=docx,png,pdf,woff2,psd,jpeg,jpg,gz,svg,map
```

Then update the table, the "Last updated" date, and add a row to the log below.
(`cloc` install: `sudo apt-get install -y cloc`.)

---

## Update log

| Date | Total LOC | Files | Notes |
|------|----------:|------:|-------|
| 2026-06-17 | 114,713 | 1,054 | Initial census over the **full `~/repos` working tree** (22 dirs, incl. third-party + personal). Superseded same day. |
| 2026-06-17 | 76,388 | 519 | **Re-scoped to PitziLabs org repos only** (14 repos). cloc 2.06. |
