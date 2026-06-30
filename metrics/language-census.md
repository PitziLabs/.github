# Lentago Labs Language Census

A periodic census of the programming/markup/config languages represented across
the **Lentago Labs org repositories**, ordered by prominence (lines of code). This
file is meant to be **regenerated periodically** — see
[Regenerating](#regenerating) for the exact, reproducible command, and log each
refresh in the [Update log](#update-log).

> **Scope.** Only repositories whose `origin` remote is under
> `github.com/lentago/`. Measured over the maintainer's `~/repos` working tree,
> so it counts what's checked out locally for each org repo (not a GitHub API
> query). Third-party clones (`firewalla-mcp`, `firewalla-tools`) and the
> personal repo (`professional-endeavors`) are **excluded**, as are local-only
> scratch dirs that aren't git repos. Generated artifacts and vendored
> dependencies are excluded (see [Methodology](#methodology)); `cloc`
> additionally **deduplicates byte-identical files**, so the deliberately-mirrored
> `CLAUDE.md` / PR-workflow text is counted once, not once per repo.
>
> **Repos in scope (15):** `bullpen`, `.github`, `firewalla-axiom-pipeline`,
> `foundry-platform-demo`, `homeassistant-config`, `homelab-observability`,
> `ice-cream-book`, `lentagolabs-dev`, `music-curator`, `office-presence`,
> `pitzilabs-dev`, `reference-checker`, `repo-template`, `shared-workflows`,
> `workstation-bootstrap`.

---

## Last updated: 2026-06-29

**Headline:** data and docs still lead — JSON (registry dumps, dashboards, config)
is ~35% and Markdown ~24%. The executing spine is Shell, then the
JavaScript/JSX/Astro web stack, then Terraform. HTML climbs into the top five this
cycle — almost entirely `reference-checker`'s committed report outputs plus the two
landing-site clones' lab pages, not hand-authored source. Python stays small in-org.

### By lines of code

Tool: `cloc 2.06`. Total: **88,063 lines of code** across **589 unique files**.

| # | Language | Code | Comment | Blank | Files | Share of code |
|---|----------|-----:|--------:|------:|------:|--------------:|
| 1 | JSON | 31,141 | 0 | 0 | 39 | 35.4% |
| 2 | Markdown | 20,914 | 48 | 10,023 | 214 | 23.7% |
| 3 | Shell (Bourne + Bash) | 8,250 | 2,332 | 1,541 | 64 | 9.4% |
| 4 | YAML | 6,805 | 1,119 | 533 | 94 | 7.7% |
| 5 | HTML | 6,179 | 261 | 674 | 21 | 7.0% |
| 6 | JSX (React) | 5,179 | 562 | 350 | 40 | 5.9% |
| 7 | HCL / Terraform | 3,582 | 962 | 754 | 70 | 4.1% |
| 8 | JavaScript | 2,330 | 260 | 270 | 7 | 2.6% |
| 9 | Astro | 1,832 | 119 | 250 | 17 | 2.1% |
| 10 | Python | 1,218 | 177 | 326 | 7 | 1.4% |
| 11 | CSS | 541 | 96 | 47 | 9 | 0.6% |
| 12 | TypeScript | 56 | 9 | 5 | 3 | 0.06% |
| 13 | TOML | 14 | 5 | 3 | 1 | 0.02% |
| 14 | Dockerfile | 8 | 20 | 8 | 2 | ~0% |

(`cloc` also reported 14 lines of plain "Text" — omitted as not a language. It
splits Shell into "Bourne Shell" 7,418 + "Bourne Again Shell" 832; folded above.)

### Programming / scripting languages only

Stripping docs (Markdown), data (JSON), config (YAML/TOML), and markup (HTML/CSS),
the code that actually executes ranks:

| # | Language | Code |
|---|----------|-----:|
| 1 | Shell / Bash | 8,250 |
| 2 | JavaScript family (JS + JSX) | 7,509 |
| 3 | Terraform / HCL *(infra-as-code)* | 3,582 |
| 4 | Astro | 1,832 |
| 5 | Python | 1,218 |
| 6 | TypeScript | 56 |

### Notes

- **JSON leads but carries no logic** — it's HA entity/device/dashboard registry
  snapshots (`homeassistant-config`), Grafana dashboard JSON
  (`homelab-observability`), and `package.json`-style config. Discount it as data
  and the picture is Markdown docs over a Shell → JS/Astro → Terraform code base.
- **HTML is output, not source** — the 6,179 lines are dominated by
  `reference-checker`'s committed `reports/*.html` (rendered analysis outputs);
  like JSON, treat it as data the repo carries rather than hand-maintained markup.
- **The web stack is double-counted right now.** Both the legacy `pitzilabs-dev`
  clone and its rebranded successor `lentagolabs-dev` carry `github.com/lentago/`
  origins, so both are in scope and the JS/JSX/Astro/CSS figures reflect *both*
  landing-site clones. They aren't byte-identical (branding text differs), so
  `cloc`'s dedup doesn't collapse them. Expect those rows to roughly halve once
  `pitzilabs-dev` is retired.
- **Shell is the most-commented code in the fleet** — 2,332 comment lines against
  8,250 of code (~28%), consistent with ops/gitops scripts written to be audited.
- **Python is small in-org.** The fleet's heavier Python (`ProxmoxMCP`,
  `firewalla-mcp`) lives in third-party clones that are out of scope; what remains
  is mostly `reference-checker` and small helpers.

---

## Methodology

Membership rule: a repo is in scope iff its `origin` remote matches
`github.com/lentago/`. Run from the fleet root (`~/repos`) with `cloc`.
Exclusions, and why:

- **VCS / dependencies / build output:** `.git`, `node_modules`, `.venv`, `venv`,
  `__pycache__`, `dist`, `build`, `.next`, `vendor`, `target`, `.terraform`,
  `.astro` (build cache), and `package-lock.json` (generated lockfile).
- **Generated artifacts:** `*/wiki-site/site/*` (MkDocs-rendered HTML) and
  `*/.playwright-mcp/*` (Playwright accessibility snapshots) — both belong to
  out-of-scope personal repos now, but the excludes are kept for safety.
- **Local-only scratch:** `archive` — dotgithub's **gitignored** holding pen
  (e.g. the unpublished portfolio mockup that embeds LAN topology). `cloc` doesn't
  honor `.gitignore`, so a never-committed file must be excluded explicitly;
  before this exclude was added it inflated HTML by ~2,144 lines.
- **Binary / asset extensions:** `docx, png, pdf, woff2, psd, jpeg, jpg, gz, svg, map`.

`cloc`'s default skipping of byte-identical duplicate files is kept on purpose —
that's what dedups the mirrored `CLAUDE.md` / PR-workflow text.

### Regenerating

```bash
cd ~/repos

# Derive the in-scope repo list from actual remotes (don't hand-maintain it):
ORG_REPOS=$(for d in */; do d="${d%/}"; \
  git -C "$d" remote get-url origin 2>/dev/null \
    | grep -q 'github.com[:/]lentago/' && printf '%s ' "$d"; done)

cloc $ORG_REPOS \
  --quiet \
  --exclude-dir=.git,node_modules,.venv,venv,__pycache__,dist,build,.next,vendor,target,.terraform,.astro,.playwright-mcp,site,archive \
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
| 2026-06-17 | 76,388 | 519 | **Re-scoped to Lentago Labs org repos only** (14 repos). cloc 2.06. |
| 2026-06-29 | 88,063 | 589 | Refresh after the Lentago Labs rebrand. **+`lentagolabs-dev`** brought into scope (now 15 repos, alongside the legacy `pitzilabs-dev` clone); **`archive/` excluded** as a gitignored local-only mockup that was adding ~2,144 HTML lines. cloc 2.06. |
