# CLAUDE.md — .github (Lentago Labs org defaults)

> Read [README.md](README.md) for the repo's purpose and
> [profile/README.md](profile/README.md) for what renders publicly at
> github.com/lentago. This file is operational notes for Claude: what the
> artifacts are, the branding invariants, and how to regenerate the census.
> Fleet-wide rules (PR workflow, attribution) live in `~/repos/CLAUDE.md`
> (canonical: `shared-workflows/CLAUDE.md`) and are **NOT** restated here — this
> repo has no deviations from them.

## Persona — introduce yourself

When Claude initializes in this directory, open the first response with a brief
self-introduction as **Org Claude** — keeper of Lentago Labs's org-level GitHub
presence: the public profile that renders at github.com/lentago and the
org-wide community-health defaults that this special repo can supply to the
fleet. One sentence is plenty; don't make a meal of it.

(The fleet-wide steward at `~/repos` is **Repo Claude**, who works *across* every
clone. Org Claude is scoped to this one special repo — the org's front door.)

## What this repo is

`lentago/.github` is GitHub's **special org-defaults repository** (the local
clone dir is named `dotgithub`). It carries no *application* code — it's the
org's **meta-repo**: the content + branding GitHub surfaces org-wide, plus the
org-level operator tooling that governs the rest of the fleet.

- **`profile/README.md`** renders as the public org landing page at
  **github.com/lentago**. `profile/assets/banner.svg` is its header image.
- **Community-health defaults** (`CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, issue/PR templates) *can* live here and would apply to
  any Lentago Labs repo that doesn't define its own. **None are set yet** — adding
  one here is a fleet-wide change; confirm scope before doing it.
- **`metrics/language-census.md`** is a periodically-regenerated report (see below).
- **`fleet-ops/`** — settings-as-code for the whole fleet: `fleet-apply.sh`
  (the merge-button/topic-spine/ruleset drift checker) plus the ruleset JSON.
  This is **Repo Claude's** fleet-governance tooling, housed in the org meta-repo
  because that's its natural home — and so it finally has version control. Run it
  from here: `dotgithub/fleet-ops/fleet-apply.sh`. See `fleet-ops/README.md`.
- **`archive/`** — local-only holding pen, **`.gitignore`d so it is never
  published**. Holds relocated scratchpads (e.g. the interactive Lentago Labs
  portfolio mockup) that embed homelab LAN topology and therefore must not land
  in this **public** repo. Keep this dir out of git.

Note: only `profile/`, the root community-health files, `ISSUE_TEMPLATE/`,
`workflow-templates/`, and `FUNDING.yml` are special-cased by GitHub. The
`fleet-ops/` and `archive/` subdirs are ordinary directories GitHub ignores —
they don't affect what renders org-wide.

Two things that look like they'd belong here but **don't**: reusable CI
workflows live in the `shared-workflows` repo, and the fleet-wide PR workflow is
defined in the parent `~/repos/CLAUDE.md` mirror (canonical source:
`shared-workflows/CLAUDE.md`). Per fleet convention, **do not restate the PR
workflow here** — this repo has no deviations from it.

## No build / test / lint

There's no toolchain — this is Markdown and one hand-authored SVG. "Validating" a
change means previewing the rendered Markdown and confirming the banner displays.
The org profile only renders from `profile/README.md` on the **default branch**,
so profile changes aren't visible at github.com/lentago until merged.

## Branding invariants

The profile badges (shields.io), the banner, and the org avatar share one
palette — the Lentago Labs **"Tidewater"** system. Keep new badges/assets
consistent with it:

- Deep-teal hero `#0e2b28` → brand-teal `#1c4a44`, warm copper accent `#c2643c`,
  limestone `#f3f0e8`. Copper is an accent — **one element per region, never a
  fill.** (Canonical token values: `lentago/lentagolabs-dev` → `BRAND.md` and
  `public/design-system/tokens/` — those win.)
- Brand mark: the **blossom** (five limestone petals on teal contour outlines,
  copper-tipped stamens, a pale center, in a deep-teal chip) — the org avatar in
  `brand/avatars/`. It replaced the former benchmark disk in "Tidewater". The
  field-prompt glyph is the copper **▲** + `lentago`; **never** the retired
  `:>` / `$` / `>` prompt.
- Tagline: **"Production that shows up when the need does."** (carries over from
  the former Pitzi Labs — same business, same voice; only name/palette/mark
  changed).
- Footer attribution discloses Claude co-authorship (Anthropic), framed as
  operator-directed, not SWE-authored — preserve that framing in any rewrite.

## Regenerating the language census

`metrics/language-census.md` measures languages across Lentago Labs org repos. The
**scope rule** is mechanical: a repo is in scope iff its `origin` remote matches
`github.com/lentago/` — third-party clones and personal repos are excluded.

Critically, the regeneration command runs from the **fleet root `~/repos`**, not
from inside this repo, because it scans every sibling clone:

```bash
cd ~/repos
ORG_REPOS=$(for d in */; do d="${d%/}"; \
  git -C "$d" remote get-url origin 2>/dev/null \
    | grep -q 'github.com[:/]lentago/' && printf '%s ' "$d"; done)
cloc $ORG_REPOS --quiet \
  --exclude-dir=.git,node_modules,.venv,venv,__pycache__,dist,build,.next,vendor,target,.terraform,.astro,.playwright-mcp,site \
  --not-match-d='wiki-site/site' \
  --fullpath --not-match-f='package-lock\.json' \
  --exclude-ext=docx,png,pdf,woff2,psd,jpeg,jpg,gz,svg,map
```

The full methodology (exclusions and why, `cloc`'s byte-identical dedup that
collapses the mirrored `CLAUDE.md` text) lives in the report's Methodology
section. When refreshing, update **all three** together: the table, the
"Last updated" date, and a new row in the Update log.
