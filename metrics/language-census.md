# PitziLabs Language Census

A periodic census of the programming/markup/config languages represented across
the local fleet, ordered by prominence (lines of code). This file is meant to be
**regenerated periodically** — see [Regenerating](#regenerating) for the exact,
reproducible command, and log each refresh in the [Update log](#update-log).

> **Scope.** Measured over the `~/repos` fleet working tree on the maintainer's
> workstation — every clone present there, which includes the PitziLabs org
> repos *plus* a third-party clone (`ProxmoxMCP`) and personal repos (`prompts`).
> It is a snapshot of what's checked out locally, not a query of the org via the
> GitHub API. Generated artifacts, vendored dependencies, and VCS metadata are
> excluded (see [Methodology](#methodology)); `cloc` additionally **deduplicates
> byte-identical files**, so the deliberately-mirrored `CLAUDE.md` / PR-workflow
> text is counted once rather than once per repo.

---

## Last updated: 2026-06-17

**Headline:** the fleet is documentation- and ops-heavy. Markdown alone is ~42% of
all code lines (and that's *after* dedup — raw it was ~98k lines), and JSON data/
config is another ~26%. The actual programming spine — what executes — is Shell,
then the JavaScript/TypeScript family, then Python, with Terraform as the infra layer.

### By lines of code

Tool: `cloc 2.06`. Total: **114,713 lines of code** across **1,054 unique files**.

| # | Language | Code | Comment | Blank | Files | Share of code |
|---|----------|-----:|--------:|------:|------:|--------------:|
| 1 | Markdown | 47,807 | 194 | 20,979 | 629 | 41.7% |
| 2 | JSON | 29,582 | 0 | 0 | 53 | 25.8% |
| 3 | Shell (Bourne + Bash) | 8,869 | 2,545 | 1,775 | 70 | 7.7% |
| 4 | YAML | 6,899 | 1,091 | 526 | 96 | 6.0% |
| 5 | HTML | 4,184 | 39 | 226 | 12 | 3.6% |
| 6 | Python | 4,149 | 1,269 | 942 | 43 | 3.6% |
| 7 | JSX (React) | 3,627 | 301 | 253 | 29 | 3.2% |
| 8 | HCL / Terraform | 3,530 | 946 | 743 | 69 | 3.1% |
| 9 | JavaScript | 2,530 | 253 | 303 | 10 | 2.2% |
| 10 | Astro | 1,737 | 98 | 245 | 15 | 1.5% |
| 11 | TypeScript | 1,290 | 34 | 111 | 15 | 1.1% |
| 12 | CSS | 314 | 33 | 20 | 3 | 0.3% |
| 13 | TOML | 85 | 5 | 11 | 2 | 0.07% |
| 14 | Dockerfile | 4 | 10 | 4 | 1 | ~0% |

(`cloc` also reported 106 lines of plain "Text" across 7 files — omitted here as
not a language. It splits Shell into "Bourne Shell" 7,785 + "Bourne Again Shell"
1,084; folded above.)

### Programming / scripting languages only

Stripping docs (Markdown), data (JSON), config (YAML/TOML), and markup (HTML/CSS),
the code that actually executes ranks:

| # | Language | Code |
|---|----------|-----:|
| 1 | Shell / Bash | 8,869 |
| 2 | JavaScript family (JS + JSX) | 6,157 |
| 3 | Python | 4,149 |
| 4 | Terraform / HCL *(infra-as-code)* | 3,530 |
| 5 | Astro | 1,737 |
| 6 | TypeScript | 1,290 |

### Notes

- **Shell is the most-commented code in the fleet** — 2,545 comment lines against
  8,869 of code (~29% comment ratio), consistent with these being ops/gitops
  scripts written to be read and audited.
- **JSON is a quarter of "code" but has zero logic** — it's registry dumps and
  config (HA entity/device snapshots, dashboards, `package.json`-style files).
  Discount it and the programming picture sharpens to Shell → JS/TS → Python.
- **Markdown's dedup gap is the mirror tax.** The fleet PR-workflow text and
  several `CLAUDE.md` blocks are intentionally mirrored across repos; `cloc`
  counts the unique content once, which is why the census shows ~48k where a
  naive `wc -l` shows ~98k.

---

## Methodology

Run from the fleet root (`~/repos`) with `cloc`. Exclusions, and why:

- **VCS / dependencies / build output:** `.git`, `node_modules`, `.venv`, `venv`,
  `__pycache__`, `dist`, `build`, `.next`, `vendor`, `target`, `.terraform`,
  `.astro` (build cache), and `package-lock.json` (generated lockfile).
- **Generated artifacts that otherwise dominate the count:**
  - `*/.playwright-mcp/*` — Playwright MCP accessibility-tree snapshots
    (~189k lines of YAML; *not* authored config).
  - `*/wiki-site/site/*` — MkDocs-rendered static site (~705k lines of HTML).
- **Binary / asset extensions:** `docx, png, pdf, woff2, psd, jpeg, jpg, gz, svg, map`.

`cloc`'s default behavior of skipping duplicate (byte-identical) files is kept on
purpose — see the mirror note above.

### Regenerating

```bash
cd ~/repos
cloc . \
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
| 2026-06-17 | 114,713 | 1,054 | Initial census. cloc 2.06. 22 repos in the working tree. |
