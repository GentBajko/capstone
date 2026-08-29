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
if ! diff <(bash skills/core/scripts/help.sh) \
          <(grep -Ev "^Write-Output @'|^'@|^# Prints" skills/core/scripts/help.ps1) >/dev/null 2>&1; then
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
#    (help has no protocol file by design)
for p in skills/core/references/protocols/*.md; do
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
  case "$n" in help|core) continue;; esac
  [ -f "skills/core/references/protocols/$n.md" ] || err "skill $n has no protocol file"
  grep -q "protocols/$n\.md" "skills/$n/SKILL.md" \
    || err "skills/$n/SKILL.md does not wire protocols/$n.md"
  grep -q 'references/core\.md' "skills/$n/SKILL.md" \
    || err "skills/$n/SKILL.md does not wire core.md"
  # the shared rules are split: writers read both files, the two chain
  # runners route rather than write and read core.md alone
  case "$n" in
    start|implementation)
      grep -q 'core-authoring\.md` is not' "skills/$n/SKILL.md" \
        || err "router $n should read core.md alone and say why" ;;
    *)
      grep -q 'and `\.\./core/references/core-authoring\.md`' "skills/$n/SKILL.md" \
        || err "skills/$n/SKILL.md does not wire core-authoring.md" ;;
  esac
done
[ -f skills/core/references/core-authoring.md ] || err "core-authoring.md is missing"
grep -q 'core-authoring\.md' skills/core/references/core.md \
  || err "core.md does not point at core-authoring.md"
grep -q 'core-authoring\.md' skills/core/references/dispatcher.md \
  || err "dispatcher.md does not load core-authoring.md"
# contributor-only material must not sit in the runtime path
grep -q '^Maintenance: each subcommand' skills/core/references/core.md \
  && err "core.md still carries the contributor Maintenance block (belongs in CONTRIBUTING.md)"
[ -f CONTRIBUTING.md ] || err "CONTRIBUTING.md is missing"
# each shared-rules section lives in exactly one of the two files
for h in 'Changelog ledger' 'Interview lifecycle' 'Hard rules' 'Read discipline'; do
  grep -q "^## .*$h" skills/core/references/core.md \
    || err "core.md lost section: $h"
  grep -q "^## .*$h" skills/core/references/core-authoring.md \
    && err "core-authoring.md duplicates core.md section: $h"
done
for h in 'Local-only outputs' 'Artifact seeding' 'Delegation installs' 'Index maintenance'; do
  grep -q "^## .*$h" skills/core/references/core-authoring.md \
    || err "core-authoring.md lost section: $h"
  grep -q "^## .*$h" skills/core/references/core.md \
    && err "core.md duplicates core-authoring.md section: $h"
done

# 3b. every protocol declares its inputs (core.md Read discipline)
for p in skills/core/references/protocols/*.md; do
  grep -q '^\*\*Reads:\*\*' "$p" || err "$(basename "$p") has no **Reads:** block"
done

# 4. protocol H1 stem == filename
for p in skills/core/references/protocols/*.md; do
  n=$(basename "$p" .md)
  head -1 "$p" | grep -Eq "^# $n( |$)" || err "H1 of $n.md does not start '# $n' ($(head -1 "$p"))"
done

# 5. every skill name appears in help.sh, README command table, README routing snippet, INSTALL.md
HELPTXT=$(bash skills/core/scripts/help.sh)
for d in skills/*/; do
  n=$(basename "$d")
  case "$n" in core) continue;; esac
  echo "$HELPTXT" | grep -Eq "^  $n( |$)" || err "help.sh missing command line for $n"
  grep -q "/capstone:$n[\` ]" README.md || err "README command table missing /capstone:$n"
  grep -Eq "(^|[ (])$n[,)]" .opencode/INSTALL.md || err "INSTALL.md missing $n"
done
ROUTE=$(sed -n '/matches a capstone skill/,/invoke capstone:/p' README.md)
for d in skills/*/; do
  n=$(basename "$d")
  case "$n" in core) continue;; esac
  echo "$ROUTE" | grep -Eq "(^|[ (])$n[,)]" || err "README routing snippet missing $n"
done

# 5b. the dispatcher's reserved-word list carries every routable
#     subcommand (on Gemini, skills/core/references/dispatcher.md is the only entry point)
ROUTELIST=$(sed -n '/The reserved subcommand words/,/each route to/p' skills/core/references/dispatcher.md)
[ -n "$ROUTELIST" ] || err "dispatcher.md reserved-subcommand sentence not found"
for p in skills/core/references/protocols/*.md; do
  n=$(basename "$p" .md)
  printf '%s' "$ROUTELIST" | grep -q "\`$n\`" || err "dispatcher.md routing list missing $n"
done

# 6. hook wiring: matcher == script guard == existing skill, and the
#    install-time global-config hook is in place
grep -q '"matcher": "capstone:help"' hooks/hooks.json || err "hooks.json matcher is not capstone:help"
grep -q '"command_name":"capstone:help"' skills/core/scripts/help-hook.sh || err "help-hook.sh guard string wrong"
grep -q 'skills/core/scripts/help-hook.sh' hooks/hooks.json || err "hooks.json does not point at help-hook.sh"
grep -q 'CLAUDE_CODE_ENTRYPOINT' skills/core/scripts/help-hook.sh \
  || err "help-hook.sh lost its terminal-only guard (GUI surfaces swallow block reasons)"
grep -q '"SessionStart"' hooks/hooks.json || err "hooks.json has no SessionStart hook"
grep -q 'init-config.sh --global' hooks/hooks.json || err "hooks.json SessionStart does not run init-config.sh --global"

# 7. config template keys identical everywhere they appear: the global
#    template's keys in both initializers, core.md, and README; the
#    project-scoped keys (never in the global template) documented in
#    core.md and README
for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1 \
         skills/core/references/core.md README.md; do
  for k in expertise teaching_mode docs_dir index_file subagent_threshold docs_in_git language; do
    grep -q "\"$k\"" "$f" || err "$f config template missing key $k"
  done
  for k in pipeline workspaces; do
    grep -q "\"$k\"" "$f" && err "$f global template carries project-scoped key $k"
  done
done
for f in skills/core/references/core.md README.md; do
  for k in pipeline workspaces; do
    grep -q "\`$k\`" "$f" || err "$f does not document project-scoped config key $k"
  done
done

# 8. .sh/.ps1 pairing (help-hook.sh exempt, lint-sync pairs with itself)
for s in skills/core/scripts/*.sh; do
  b=$(basename "$s" .sh)
  case "$b" in help-hook) continue;; esac
  [ -f "skills/core/scripts/$b.ps1" ] || err "$b.sh has no $b.ps1 twin"
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
  if git grep -l 'archdesign' -- . ':!skills/core/scripts/lint-sync.*' >/dev/null 2>&1; then
    err "stale 'archdesign' references: $(git grep -l 'archdesign' -- . ':!skills/core/scripts/lint-sync.*' | tr '\n' ' ')"
  fi
  # 10b. the removed commands must not be routable again by accident:
  #      no protocol file, no wrapper, no help line, no dispatcher word.
  for n in ask changelog guides onboarding; do
    [ -e "skills/$n" ] && err "removed skill skills/$n/ is back"
    [ -e "skills/core/references/protocols/$n.md" ] \
      && err "removed protocol $n.md is back"
    bash skills/core/scripts/help.sh | grep -Eq "^  $n( |$)" \
      && err "help.sh advertises removed command $n"
    sed -n '/The reserved subcommand words/,/each route to/p' \
      skills/core/references/dispatcher.md | grep -q "\`$n\`" \
      && err "dispatcher.md still routes removed command $n"
  done
  # 10c. the index lives in the docs area and carries no stamp columns
  for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1 \
           skills/core/references/core.md README.md; do
    grep -q '"index_file": "docs/capstone/00-index.md"' "$f" \
      || err "$f does not carry the docs-area index_file default"
  done
  grep -q 'Topic | File | Commit' skills/core/references/protocols/generate.md \
    && err "generate.md still specifies stamp columns in the index table"
  for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1; do
    grep -q '00-index.md' "$f" || err "$f lost the root-DESIGN.md index migration"
  done
else
  echo "note: dead-name check skipped (not a git checkout)"
fi

# 11. every writing protocol carries its changelog pointer, the exempt
#     ones say so, and the old opt-in is gone (core.md hard rule 5 is
#     only as good as its sites)
for n in groom plan implement mockup logic design architecture \
         code-prefs stack build be-review fe-review \
         generate sync doctor; do
  grep -q 'changelog entry' "skills/core/references/protocols/$n.md" \
    || err "protocol $n.md has no changelog-entry step"
done
grep -q 'Changelog ledger' skills/core/references/core.md \
  || err "core.md has no Changelog ledger section"
if grep -q 'Offer `changelog' skills/core/references/protocols/implement.md; then
  err "implement.md still carries the old opt-in changelog offer"
fi
# the ledger outlived the `changelog` command: changelog.md is still
# written by every stage, but nothing may route to a protocol for it
grep -q 'Merges:' skills/core/references/core.md \
  || err "core.md lost the changelog merge-resolution rule"

# 12. the local-only ignore list is identical in both initializers and
#     documented in core.md (hand-synced across three files); changelog.md
#     is part of the reference and must never reappear in the templates,
#     and both initializers must carry the unignore migration for it
for r in 'features/' '\*-interview.md' 'capstone.json' 'review.md' 'be-review.md' 'fe-review.md'; do
  for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1; do
    grep -q "^$r$" "$f" || err "$f ignore template missing rule $r"
  done
done
for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1; do
  grep -q "^changelog\.md$" "$f" && err "$f ignore template still lists changelog.md (it follows docs_in_git now)"
  grep -q "unignored: changelog.md" "$f" || err "$f lost the changelog.md unignore migration"
done
grep -q 'Local-only outputs' skills/core/references/core-authoring.md \
  || err "core-authoring.md has no Local-only outputs section"
for f in skills/core/scripts/init-config.sh skills/core/scripts/init-config.ps1; do
  grep -q 'docs/design' "$f" || err "$f dropped the legacy docs/design migration"
done

# 12b. the git standards code-craft.md defines are wired at every site
#      that branches or commits
for n in plan build implement; do
  grep -q 'code-craft' "skills/core/references/protocols/$n.md" \
    || err "protocol $n.md does not reference code-craft.md"
done
grep -q '^## Git: branches, commits' skills/core/references/code-craft.md \
  || err "code-craft.md has no Git section"
grep -q "Git section" skills/core/references/protocols/implement.md \
  || err "implement.md does not cite code-craft's Git section"

# 13. bash syntax of every .sh
for s in skills/core/scripts/*.sh; do
  bash -n "$s" 2>/dev/null || err "bash syntax error in $s"
done


# 14. the pipeline order is spelled identically everywhere it appears
PIPE='mockup -> logic -> design -> architecture -> code-prefs -> stack -> build'
for f in skills/core/scripts/help.sh skills/core/scripts/help.ps1 skills/start/SKILL.md; do
  grep -qF "$PIPE" "$f" || err "$f missing the pipeline-order string"
done
grep -qF 'mockup → logic → design → architecture → code-prefs → stack → build' README.md \
  || err "README.md missing the pipeline-order string"

[ "$FAIL" -eq 0 ] && echo "lint-sync: all invariants hold" || echo "lint-sync: FAILURES above"
exit $FAIL
