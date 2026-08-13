#!/usr/bin/env bash
# Asserts every keep-in-sync-by-hand invariant in this plugin.
# Run from the repo root. Exit non-zero listing each failure.
# help-hook.sh is exempt from the .sh/.ps1 pair rule: hooks.json invokes
# bash explicitly, so it is bash-only by design.
# POSIX-portable regex only: no GNU-only \| or \b, so this runs on
# macOS/BSD grep as well as GNU.
set -u
cd "$(dirname "$0")/../../.." || exit 1
FAIL=0
err() { echo "FAIL: $*"; FAIL=1; }

MANIFESTS=".claude-plugin/plugin.json .claude-plugin/marketplace.json
.codex-plugin/plugin.json .cursor-plugin/plugin.json
.kimi-plugin/plugin.json gemini-extension.json"

IN_GIT=0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && IN_GIT=1

# 1. help.sh body == help.ps1 body
if ! diff <(bash skills/docs/scripts/help.sh) \
          <(grep -Ev "^Write-Output @'|^'@|^# Prints" skills/docs/scripts/help.ps1) >/dev/null 2>&1; then
  err "help.sh and help.ps1 texts differ"
fi

# 2. exactly one version string per manifest, and one distinct value overall
VERSIONS=""
for f in $MANIFESTS; do
  v=$(grep '"version"' "$f" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/')
  c=$(printf '%s\n' "$v" | grep -c '.')
  if [ "$c" -ne 1 ]; then
    err "$f does not yield exactly one version string (got $c)"
    continue
  fi
  VERSIONS="$VERSIONS$v
"
done
UNIQ=$(printf '%s' "$VERSIONS" | grep '.' | sort -u)
if [ "$(printf '%s\n' "$UNIQ" | grep -c '.')" -gt 1 ]; then
  err "version mismatch across manifests: $(printf '%s' "$UNIQ" | tr '\n' ' ')"
fi

# 3. protocol files <-> skill dirs, and every wrapper is loadable and wired
#    (docs and help have no protocol file by design)
for p in skills/docs/references/protocols/*.md; do
  n=$(basename "$p" .md)
  [ -d "skills/$n" ] || err "protocol $n.md has no skills/$n/ wrapper"
done
for d in skills/*/; do
  n=$(basename "$d")
  if [ ! -f "skills/$n/SKILL.md" ]; then
    err "skill $n has no SKILL.md"
    continue
  fi
  fm=$(sed -n '2,10p' "skills/$n/SKILL.md" | sed -n 's/^name: *//p' | head -1)
  [ "$fm" = "$n" ] || err "skills/$n/SKILL.md frontmatter name is '$fm', expected '$n'"
  case "$n" in docs|help) continue;; esac
  [ -f "skills/docs/references/protocols/$n.md" ] || err "skill $n has no protocol file"
  grep -q "protocols/$n\.md" "skills/$n/SKILL.md" \
    || err "skills/$n/SKILL.md does not wire protocols/$n.md"
done

# 4. protocol H1 stem == filename
for p in skills/docs/references/protocols/*.md; do
  n=$(basename "$p" .md)
  head -1 "$p" | grep -Eq "^# $n( |$)" || err "H1 of $n.md does not start '# $n' ($(head -1 "$p"))"
done

# 5. every skill name appears in help.sh, README command table, README routing snippet, INSTALL.md
HELPTXT=$(bash skills/docs/scripts/help.sh)
for d in skills/*/; do
  n=$(basename "$d")
  echo "$HELPTXT" | grep -Eq "^  $n( |$)" || err "help.sh missing command line for $n"
  grep -q "/capstone:$n[\` ]" README.md || err "README command table missing /capstone:$n"
  grep -Eq "(^|[ (])$n[,)]" .opencode/INSTALL.md || err "INSTALL.md missing $n"
done
ROUTE=$(sed -n '/matches a capstone skill/,/invoke capstone:/p' README.md)
for d in skills/*/; do
  n=$(basename "$d")
  echo "$ROUTE" | grep -Eq "(^|[ (])$n[,)]" || err "README routing snippet missing $n"
done

# 5b. the docs dispatcher's reserved-word list carries every routable
#     subcommand (on Gemini, docs/SKILL.md is the only entry point)
ROUTELIST=$(sed -n '/The reserved subcommand words/,/each route to/p' skills/docs/SKILL.md)
[ -n "$ROUTELIST" ] || err "docs/SKILL.md reserved-subcommand sentence not found"
for p in skills/docs/references/protocols/*.md; do
  n=$(basename "$p" .md)
  printf '%s' "$ROUTELIST" | grep -q "\`$n\`" || err "docs/SKILL.md routing list missing $n"
done

# 6. hook wiring: matcher == script guard == existing skill
grep -q '"matcher": "capstone:help"' hooks/hooks.json || err "hooks.json matcher is not capstone:help"
grep -q '"command_name":"capstone:help"' skills/docs/scripts/help-hook.sh || err "help-hook.sh guard string wrong"
grep -q 'skills/docs/scripts/help-hook.sh' hooks/hooks.json || err "hooks.json does not point at help-hook.sh"

# 7. config template keys identical everywhere they appear
for f in skills/docs/scripts/init-config.sh skills/docs/scripts/init-config.ps1 \
         skills/docs/references/core.md README.md; do
  for k in expertise docs_dir index_file subagent_threshold docs_in_git language pipeline; do
    grep -q "\"$k\"" "$f" || err "$f config template missing key $k"
  done
done

# 8. .sh/.ps1 pairing (help-hook.sh exempt, lint-sync pairs with itself)
for s in skills/docs/scripts/*.sh; do
  b=$(basename "$s" .sh)
  case "$b" in help-hook) continue;; esac
  [ -f "skills/docs/scripts/$b.ps1" ] || err "$b.sh has no $b.ps1 twin"
done

# 9. every tracked .json parses (a stray comma in marketplace.json breaks
#    installation for every user, and no grep-based check would see it)
if [ "$IN_GIT" -eq 1 ] && command -v python3 >/dev/null 2>&1; then
  for f in $(git ls-files '*.json'); do
    python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null \
      || err "invalid JSON: $f"
  done
else
  echo "note: JSON syntax check skipped (needs a git checkout and python3)"
fi

# 10. no dead names anywhere tracked (lint scripts excluded: they carry
# the search literal themselves)
if [ "$IN_GIT" -eq 1 ]; then
  if git grep -l 'archdesign' -- . ':!skills/docs/scripts/lint-sync.*' >/dev/null 2>&1; then
    err "stale 'archdesign' references: $(git grep -l 'archdesign' -- . ':!skills/docs/scripts/lint-sync.*' | tr '\n' ' ')"
  fi
else
  echo "note: dead-name check skipped (not a git checkout)"
fi

# 11. every writing protocol carries its changelog pointer, the exempt
#     ones say so, and the old opt-in is gone (core.md hard rule 5 is
#     only as good as its sites)
for n in groom plan implement mockup logic architecture code-prefs stack \
         build review guides onboarding; do
  grep -q 'changelog entry' "skills/docs/references/protocols/$n.md" \
    || err "protocol $n.md has no changelog-entry step"
done
grep -q 'changelog entry' skills/docs/SKILL.md \
  || err "docs/SKILL.md has no changelog-entry step"
grep -q 'Changelog ledger' skills/docs/references/core.md \
  || err "core.md has no Changelog ledger section"
if grep -q 'Offer `changelog' skills/docs/references/protocols/implement.md; then
  err "implement.md still carries the old opt-in changelog offer"
fi
for n in check-docs ask; do
  grep -Eq 'no changelog entry|never appends a changelog' \
    "skills/docs/references/protocols/$n.md" \
    || err "protocol $n.md lacks its explicit changelog exemption"
done

# 12. the local-only ignore list is identical in both initializers and
#     documented in core.md (hand-synced across three files)
for r in 'features/' '\*-interview.md' 'capstone.json' 'review.md' 'changelog.md'; do
  for f in skills/docs/scripts/init-config.sh skills/docs/scripts/init-config.ps1; do
    grep -q "^$r$" "$f" || err "$f ignore template missing rule $r"
  done
done
grep -q 'Local-only outputs' skills/docs/references/core.md \
  || err "core.md has no Local-only outputs section"

# 13. bash syntax of every .sh
for s in skills/docs/scripts/*.sh; do
  bash -n "$s" 2>/dev/null || err "bash syntax error in $s"
done

[ "$FAIL" -eq 0 ] && echo "lint-sync: all invariants hold" || echo "lint-sync: FAILURES above"
exit $FAIL
