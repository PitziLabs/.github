#!/usr/bin/env bash
# ============================================================================
# fleet-apply.sh — enforce PitziLabs fleet repo settings that GitHub templates
# and branch rulesets do NOT carry: merge-button options and the topic spine.
#
#   ./fleet-apply.sh                 # check ALL non-archived org repos (read-only)
#   ./fleet-apply.sh --apply         # apply fixes to ALL repos
#   ./fleet-apply.sh --repo NAME     # scope to one repo
#   ./fleet-apply.sh --apply --repo NAME
#
# Read-only by default. Only --apply mutates. Branch protection is intentionally
# NOT managed here — that's the org-level `fleet-baseline` ruleset (org-ruleset.json)
# plus per-repo rulesets that add required status checks. This script reports
# ruleset presence but never changes it.
# ============================================================================
set -euo pipefail

ORG=PitziLabs
MODE=check
ONLY=""
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SPINE_TOPICS=(pitzilabs claude)
# Sentinel: the copy-pasted review prompt that caused a fleet-wide regression.
# Any repo other than workstation-bootstrap carrying this is mis-customized.
BOILERPLATE='bash bootstrap scripts for Linux workstations'

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) MODE=apply ;;
    --check) MODE=check ;;
    --repo)  ONLY="${2:?--repo needs a name}"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

echo "fleet-apply: mode=$MODE org=$ORG ${ONLY:+repo=$ONLY}"
echo

if [ -n "$ONLY" ]; then
  repos="$ONLY"
else
  repos=$(gh repo list "$ORG" --no-archived --limit 100 --json name --jq '.[].name' | sort)
fi

drift_total=0

for r in $repos; do
  # --- merge-button settings ---
  read -r squash merge rebase auto del private <<<"$(gh api "repos/$ORG/$r" \
    --jq '"\(.allow_squash_merge) \(.allow_merge_commit) \(.allow_rebase_merge) \(.allow_auto_merge) \(.delete_branch_on_merge) \(.private)"')"

  declare -a fixes=()
  [ "$squash" = true ]  || fixes+=(--enable-squash-merge)
  [ "$merge"  = false ] || fixes+=(--enable-merge-commit=false)
  [ "$rebase" = false ] || fixes+=(--enable-rebase-merge=false)
  [ "$del"    = true ]  || fixes+=(--delete-branch-on-merge)
  # Auto-merge isn't available on private repos on the Free plan. Don't nag
  # about an unachievable setting — note it instead of counting it as drift.
  auto_note=""
  if [ "$auto" != true ]; then
    if [ "$private" = true ]; then
      auto_note=" (auto-merge unavailable on private repo — plan limit)"
    else
      fixes+=(--enable-auto-merge)
    fi
  fi

  # --- spine topics ---
  mapfile -t have_topics < <(gh api "repos/$ORG/$r/topics" \
    -H "Accept: application/vnd.github.mercy-preview+json" --jq '.names[]' 2>/dev/null || true)
  declare -a add_topics=()
  for want in "${SPINE_TOPICS[@]}"; do
    printf '%s\n' "${have_topics[@]}" | grep -qxF "$want" || add_topics+=("$want")
  done

  # --- informational: branch ruleset presence ---
  # The rulesets API (like auto-merge) needs Pro for private repos, so a 403
  # here is a plan limit, not a real "no rulesets" answer.
  rs_json=$(gh api "repos/$ORG/$r/rulesets" 2>/dev/null || true)
  ruleset_missing=0
  if printf '%s' "$rs_json" | grep -q 'Upgrade to GitHub Pro\|"status": *"403"'; then
    rs_count="n/a (private/plan)"   # rulesets API needs Pro for private repos
  else
    rs_count=$(printf '%s' "$rs_json" | jq '[.[] | select(.target=="branch")] | length' 2>/dev/null || echo "?")
    [ "$rs_count" = "0" ] && ruleset_missing=1
  fi

  # --- informational: boilerplate review-prompt guard ---
  warn=""
  if [ "$r" != "workstation-bootstrap" ]; then
    body=$(gh api "repos/$ORG/$r/contents/.github/workflows/claude-code-review.yml?ref=HEAD" \
            --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)
    case "$body" in
      *"$BOILERPLATE"*) warn=" ⚠ review_prompt still has workstation-bootstrap boilerplate" ;;
    esac
  fi

  # --- report / apply ---
  if [ ${#fixes[@]} -eq 0 ] && [ ${#add_topics[@]} -eq 0 ] && [ -z "$warn" ] && [ "$ruleset_missing" -eq 0 ]; then
    printf '  ✓ %-26s settings ok (branch rulesets: %s)%s\n' "$r" "$rs_count" "$auto_note"
  else
    drift_total=$((drift_total+1))
    printf '  • %-26s ' "$r"
    [ ${#fixes[@]} -gt 0 ]      && printf 'merge-fixes=[%s] ' "${fixes[*]}"
    [ ${#add_topics[@]} -gt 0 ] && printf 'add-topics=[%s] ' "${add_topics[*]}"
    [ "$ruleset_missing" -eq 1 ] && printf 'no-branch-ruleset '
    [ -n "$warn" ]              && printf '%s' "$warn"
    [ -n "$auto_note" ]        && printf '%s' "$auto_note"
    printf '\n'
    if [ "$MODE" = apply ]; then
      [ ${#fixes[@]} -gt 0 ] && gh repo edit "$ORG/$r" "${fixes[@]}" >/dev/null
      for t in "${add_topics[@]}"; do gh repo edit "$ORG/$r" --add-topic "$t" >/dev/null; done
      if [ "$ruleset_missing" -eq 1 ]; then
        gh api -X POST "repos/$ORG/$r/rulesets" --input "$SCRIPT_DIR/repo-ruleset.json" >/dev/null \
          && echo "      → created main branch ruleset"
      fi
      echo "      → applied (note: review_prompt warnings are NOT auto-fixed — edit by hand)"
    fi
  fi
  unset fixes add_topics
done

echo
if [ "$MODE" = check ]; then
  echo "check complete — $drift_total repo(s) with drift. Re-run with --apply to fix merge/topics."
else
  echo "apply complete."
fi
