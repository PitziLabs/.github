# brand/avatars — Lentago Labs identity marks

Canonical GitHub avatar marks for the Lentago Labs identity. The org mark is the
brand **benchmark disk** — a surveyor's survey marker (copper ring, cream
crosshair, center point, station tick) set in a deep-teal chip, per the
[Lentago Labs brand contract](https://github.com/lentago/lentagolabs-dev/blob/main/BRAND.md).
It comes in a **rounded** (avatar) and a **square** (sharp-corner) variant.

The personal mark is still the `<cjp:>` command-prompt chip — that's the
operator's individual `github.com/cpitzi` identity, not the Lentago Labs org
brand, so it is intentionally left in its own bracket lettermark.

| File | Mark | Corners | Used as |
|------|------|---------|---------|
| `lentago-mark.svg` / `lentago-mark-512.png` | benchmark disk | rounded | **Org** avatar — `github.com/lentago` |
| `cjp-brackets-navy.svg` / `cjp-brackets-navy-512.png` | `<cjp:>` | rounded | **Personal** avatar — `github.com/cpitzi` |
| `lentago-mark-square.svg` / `lentago-mark-square-512.png` | benchmark disk | square | Org mark on full-square surfaces |
| `cjp-brackets-navy-square.svg` / `cjp-brackets-navy-square-512.png` | `<cjp:>` | square | Personal mark on full-square surfaces |

GitHub **circle-crops** avatars, so the rounded variant is what you upload there;
the square variants are for surfaces that show the full square edge (favicons,
slides, og/social cards, print).

## Tokens — "Tidewater"

Deep-teal chip `#0e2b28` · copper ring/center/tick `#c2643c` · limestone
crosshair `#f3f0e8`. The benchmark disk is drawn (pure SVG geometry) — no font
dependency. The `<cjp:>` personal mark keeps its own navy `#1c3552` · orange
`#e08438` · cream `#faf7f2` palette in JetBrains Mono 700, lowercase.

Full palette + mark rationale: `lentago/lentagolabs-dev` → `BRAND.md` and
`public/design-system/tokens/`.

## Notes

- **The `.svg` is the source of truth.** The `-512.png` is the rendered artifact
  that gets uploaded to GitHub — re-render at any size from the SVG.
- The benchmark-disk PNGs are pure vector geometry, so any SVG rasterizer renders
  them faithfully (these were rendered headless at 512×512 with transparent
  corners). The `<cjp:>` lettermark PNG needs the self-hosted JetBrains Mono, so
  it is rendered via headless Chrome (harness + history in
  `lentago/pitzilabs-dev` → `lab/brand-assets/`).
- **GitHub avatars are a manual upload** — there is no API/`gh` path. Org →
  Org Settings → Profile → avatar; personal → Settings → Profile → Profile picture.
- The org mark is centered to survive GitHub's circle-crop.
