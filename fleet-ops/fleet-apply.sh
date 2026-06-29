#!/usr/bin/env bash
# ============================================================================
# fleet-apply.sh — enforce Lentago Labs fleet repo settings that GitHub templates
# and branch rulesets do NOT carry: merge-button options and the topic spine.
#
#   ./fleet-apply.sh                 # check ALL non-archived org repos (read-only)
#   ./fleet-apply.sh --apply         # apply merge/topic fixes to ALL repos
#   ./fleet-apply.sh --repo NAME     # scope to one repo
#   ./fleet-apply.sh --apply --repo NAME
#   ./fleet-apply.sh --prune-branches         # delete merged-residue branches fleet-wide
#   ./fleet-apply.sh --prune-branches --repo NAME
#
# Read-only by default. Only --apply (settings) and --prune-branches (branch
# deletion) mutate; they are independent flags so the destructive branch sweep
# is always opt-in. delete_branch_on_merge auto-removes a head branch when its
# PR merges going forward, but it does NOT retroactively clean branches whose PR
# merged before the setting was enabled, nor abandoned no-PR branches — this scan
# closes that gap. Branch protection is intentionally NOT managed here — that's
# the org-level `fleet-baseline` ruleset (org-ruleset.json) plus per-repo rulesets
# that add required status checks. This script reports ruleset presence but never
# changes it.
# ============================================================================
set -euo pipefail

ORG=lentago
MODE=check
PRUNE=0
ONLY=""
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SPINE_TOPICS=(lentago claude)
# Sentinel: the copy-pasted review prompt that caused a fleet-wide regression.
# Any repo other than workstation-bootstrap carrying this is mis-customized.
BOILERPLATE='bash bootstrap scripts for Linux workstations'

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) MODE=apply ;;
    --check) MODE=check ;;
    --prune-branches) PRUNE=1 ;;
    --repo)  ONLY="${2:?--repo needs a name}"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

echo "fleet-apply: mode=$MODE$([ "$PRUNE" = 1 ] && echo ' prune-branches=on') org=$ORG ${ONLY:+repo=$ONLY}"
echo

if [ -n "$ONLY" ]; then
  repos="$ONLY"
else
  repos=$(gh repo list "$ORG" --no-archived --limit 100 --json name --jq '.[].name' | sort)
fi

drift_total=0
pruned_total=0
orphan_total=0

for r in $repos; do
  # --- merge-button settings (also grab default branch for the residue scan) ---
  read -r squash merge rebase auto del private def <<<"$(gh api "repos/$ORG/$r" \
    --jq '"\(.allow_squash_merge) \(.allow_merge_commit) \(.allow_rebase_merge) \(.allow_auto_merge) \(.delete_branch_on_merge) \(.private) \(.default_branch)"')"

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

  # --- leftover branch scan ---
  # delete_branch_on_merge only fires on a merge AFTER it was enabled, and never
  # for branches that were abandoned without a merged PR. Classify each
  # non-default branch by its PR association:
  #   merged PR + no open PR  → residue, safe to prune (content is in main history)
  #   open PR                 → active, leave alone
  #   no PR at all            → orphan, REPORT ONLY (a human must confirm whether
  #                             its commits already landed on main some other way)
  declare -a residue=() orphans=()
  while IFS= read -r b; do
    [ -z "$b" ] && continue
    [ "$b" = "$def" ] && continue
    states=$(gh pr list -R "$ORG/$r" --head "$b" --state all --json state \
               --jq '.[].state' 2>/dev/null || true)
    if printf '%s\n' "$states" | grep -qx OPEN; then
      continue                                   # active PR — hands off
    elif printf '%s\n' "$states" | grep -qx MERGED; then
      residue+=("$b")
    else
      orphans+=("$b")
    fi
  done < <(gh api --paginate "repos/$ORG/$r/branches?per_page=100" --jq '.[].name' 2>/dev/null || true)

  # --- report / apply ---
  if [ ${#fixes[@]} -eq 0 ] && [ ${#add_topics[@]} -eq 0 ] && [ -z "$warn" ] && [ "$ruleset_missing" -eq 0 ] \
     && [ ${#residue[@]} -eq 0 ] && [ ${#orphans[@]} -eq 0 ]; then
    printf '  ✓ %-26s settings ok (branch rulesets: %s)%s\n' "$r" "$rs_count" "$auto_note"
  else
    drift_total=$((drift_total+1))
    pruned_total=$((pruned_total + ${#residue[@]}))
    orphan_total=$((orphan_total + ${#orphans[@]}))
    printf '  • %-26s ' "$r"
    [ ${#fixes[@]} -gt 0 ]      && printf 'merge-fixes=[%s] ' "${fixes[*]}"
    [ ${#add_topics[@]} -gt 0 ] && printf 'add-topics=[%s] ' "${add_topics[*]}"
    [ "$ruleset_missing" -eq 1 ] && printf 'no-branch-ruleset '
    [ ${#residue[@]} -gt 0 ]    && printf '%s-residue=[%s] ' "$([ "$PRUNE" = 1 ] && echo pruning || echo merged)" "${residue[*]}"
    [ ${#orphans[@]} -gt 0 ]    && printf 'orphan-branches=[%s] ' "${orphans[*]}"
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
    if [ "$PRUNE" = 1 ] && [ ${#residue[@]} -gt 0 ]; then
      for b in "${residue[@]}"; do
        gh api -X DELETE "repos/$ORG/$r/git/refs/heads/$b" >/dev/null \
          && echo "      → pruned merged-residue branch: $b"
      done
    fi
    [ ${#orphans[@]} -gt 0 ] && echo "      → orphan branch(es) left for manual review (no PR — verify content landed on main before deleting)"
  fi
  unset fixes add_topics residue orphans
done

echo
if [ "$PRUNE" = 1 ]; then
  echo "branch prune complete — $pruned_total merged-residue branch(es) deleted; $orphan_total orphan(s) left for manual review."
elif [ "$pruned_total" -gt 0 ] || [ "$orphan_total" -gt 0 ]; then
  echo "branch scan — $pruned_total merged-residue branch(es) prunable (re-run with --prune-branches), $orphan_total orphan(s) need manual review."
fi
if [ "$MODE" = check ]; then
  echo "check complete — $drift_total repo(s) with drift. Re-run with --apply to fix merge/topics."
else
  echo "apply complete."
fi
