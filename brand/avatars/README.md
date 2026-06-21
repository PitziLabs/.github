# brand/avatars — PitziLabs identity marks

Canonical GitHub avatar marks for the PitziLabs identity. Both are the brand
**chip** — a navy square with the `<…:>` command-prompt mark inside (orange
brackets, cream glyphs), per the Pitzi Labs brand contract. Each comes in a
**rounded** (avatar) and a **square** (sharp-corner) variant.

| File | Mark | Corners | Used as |
|------|------|---------|---------|
| `pl-navy.svg` / `pl-navy-512.png` | `<pl:>` | rounded | **Org** avatar — `github.com/PitziLabs` |
| `cjp-brackets-navy.svg` / `cjp-brackets-navy-512.png` | `<cjp:>` | rounded | **Personal** avatar — `github.com/cpitzi` |
| `pl-navy-square.svg` / `pl-navy-square-512.png` | `<pl:>` | square | Org mark on full-square surfaces |
| `cjp-brackets-navy-square.svg` / `cjp-brackets-navy-square-512.png` | `<cjp:>` | square | Personal mark on full-square surfaces |

GitHub **circle-crops** avatars, so the rounded variant is what you upload there;
the square variants are for surfaces that show the full square edge (favicons,
slides, og/social cards, print).

## Tokens

Navy chip `#1c3552` · orange brackets/`:>` `#e08438` · cream glyphs `#faf7f2` ·
JetBrains Mono 700. The mark is **lowercase** by brand rule.

## Notes

- **The `.svg` is the source of truth.** The `-512.png` is the rendered artifact
  that gets uploaded to GitHub — re-render at any size from the SVG.
- The PNGs were rendered via headless Chrome with the site's self-hosted JetBrains
  Mono (the render harness + decision history live in
  `PitziLabs/pitzilabs-dev` → `lab/brand-assets/`).
- **GitHub avatars are a manual upload** — there is no API/`gh` path. Org →
  Org Settings → Profile → avatar; personal → Settings → Profile → Profile picture.
- Brand contract: `PitziLabs/pitzilabs-dev` → `BRAND.md` (the chip spec lives under
  "Brand mark"). GitHub circle-crops avatars; these marks are centered to survive it.
