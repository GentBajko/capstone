#!/usr/bin/env bash
# Asserts every keep-in-sync-by-hand invariant in this plugin.
# Run from the repo root. Exit non-zero listing each failure.
# Every script here is bash, on every platform: on Windows that means
# Git Bash, which ships with Git for Windows and which hooks.json has
# always required anyway (its SessionStart command is an unconditional
# `bash`). The PowerShell twins were hand-mirrored, never executed in
# CI after the Windows runner went, and every defect they ever had was
# a sync defect rather than a logic one. One implementation cannot
# drift; check 8 fails if a .ps1 reappears.
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
    start|feature)
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
for h in 'Local-only outputs' 'Artifact seeding' 'Index maintenance'; do
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

# 5c. docs/commands.md documents every command. A command reference that
#      silently omits a command is worse than none: it reads as complete.
[ -f docs/commands.md ] || err "docs/commands.md is missing"
for d in skills/*/; do
  n=$(basename "$d")
  case "$n" in core) continue;; esac
  grep -q "\`$n\`\|\`$n " docs/commands.md \
    || err "docs/commands.md does not document $n"
done
grep -q 'MAP CHECK: current' docs/commands.md \
  || err "docs/commands.md does not show the MAP CHECK verdict line"
grep -q 'MAP REVIEW: clean' docs/commands.md \
  || err "docs/commands.md does not show the MAP REVIEW verdict line"

# 5b. the dispatcher's reserved-word list carries every routable
#     subcommand (on Gemini, skills/core/references/dispatcher.md is the only entry point)
# both anchors must be present: without the end anchor sed runs to EOF
# and the check silently degrades into "is the name anywhere in the file"
grep -q 'The reserved subcommand words' skills/core/references/dispatcher.md \
  || err "dispatcher.md reserved-subcommand sentence not found"
grep -q 'each route to' skills/core/references/dispatcher.md \
  || err "dispatcher.md routing sentence lost its 'each route to' anchor"
ROUTELIST=$(sed -n '/The reserved subcommand words/,/each route to/p' skills/core/references/dispatcher.md)
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
for f in skills/core/scripts/init-config.sh \
         skills/core/references/core.md README.md; do
  for k in expertise teaching_mode docs_dir index_file subagent_threshold \
           docs_in_git language non_interactive extract interfaces \
           interfaces_frontmatter cross_repo redact; do
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

# 7b. the cross_repo and redact template lines are one string each in the
#     initializer and core.md, trailing comment included (map joined the
#     list of consulting protocols; redact's comment defines what `*`
#     matches), and the known_as / To: unknown contract is spelled at
#     every site quarry parses against
XREPO_INIT=$(grep '"cross_repo"' skills/core/scripts/init-config.sh | head -1)
XREPO_CORE=$(grep '"cross_repo"' skills/core/references/core.md | head -1)
REDACT_INIT=$(grep '"redact"' skills/core/scripts/init-config.sh | head -1)
REDACT_CORE=$(grep '"redact"' skills/core/references/core.md | head -1)
# both empty compares equal, so a template line that vanished from both
# files would pass the byte compare; require each side to exist first.
[ -n "$XREPO_INIT" ] || err "init-config.sh has no cross_repo template line"
[ -n "$XREPO_CORE" ] || err "core.md has no cross_repo template line"
[ "$XREPO_INIT" = "$XREPO_CORE" ] \
  || err "cross_repo template line differs between init-config.sh and core.md"
[ -n "$REDACT_INIT" ] || err "init-config.sh has no redact template line"
[ -n "$REDACT_CORE" ] || err "core.md has no redact template line"
[ "$REDACT_INIT" = "$REDACT_CORE" ] \
  || err "redact template line differs between init-config.sh and core.md"
for f in skills/core/references/topics.md \
         skills/core/references/protocols/map.md \
         skills/core/references/core.md docs/commands.md README.md; do
  grep -q 'known_as' "$f" || err "$f does not mention the known_as frontmatter key"
done
grep -q 'quarry docs list --json' skills/core/references/protocols/map.md \
  || err "map.md interfaces pass does not consult quarry docs list --json"
grep -q 'write `unknown` in `To`' skills/core/references/topics.md \
  || err "topics.md lost the To: unknown rule"
# scoped to the prose paragraph: core.md's template comment (compared byte
# for byte above) already carries "cross_repo" and "map" on one line, so an
# unscoped grep would only restate that compare.
sed -n '/^`cross_repo` (/,/^$/p' skills/core/references/core.md \
  | grep -q '`map`' \
  || err "core.md cross_repo paragraph does not name map"

# 7c. the <repo> a protocol hands to quarry is the workspace name in a
#     monorepo. core.md states the contract once; every protocol that
#     runs `quarry docs deps <repo>` must apply it, or groom and plan
#     query the monorepo's name and see no consumers.
#     Every phrase pin below is matched against the file flattened to
#     one line (newlines to spaces, runs of spaces squeezed) so
#     re-wrapping a paragraph without changing a word cannot turn the
#     gate red.
tr '\n' ' ' < skills/core/references/core.md | tr -s ' ' \
  | grep -q 'The workspace name is the quarry target name' \
  || err "core.md lost the workspace/quarry naming contract"
PROTOS=$(grep -l 'quarry docs deps <repo>' skills/core/references/protocols/*.md)
[ -n "$PROTOS" ] || err "no protocol runs quarry docs deps <repo>"
for p in $PROTOS; do
  tr '\n' ' ' < "$p" | tr -s ' ' | grep -q 'when `workspaces` is configured' \
    || err "$(basename "$p") runs quarry docs deps <repo> without core.md's workspaces naming rule"
done
tr '\n' ' ' < docs/commands.md | tr -s ' ' | grep -q 'workspace name' \
  || err "docs/commands.md does not say quarry is queried by workspace name"
#     topics.md's interfaces format rule is the one surface a doc author
#     reads while filling a From/To cell, so the join key must name the
#     workspace spelling there too.
tr '\n' ' ' < skills/core/references/topics.md | tr -s ' ' \
  | grep -q 'the workspace name (which is also the quarry target name' \
  || err "topics.md interfaces join-key rule lost the workspace-name clause"

# 7d. redact's default list is spelled once. init-config.sh's and
#     core.md's config templates and README's block carry it as a config
#     line; topics.md's operations rule quotes the same list in prose, so
#     a project reading only the topic rule redacts the same names map's
#     config does; the review workflow's headless config repeats it.
REDACT='"redact": \["\*_SECRET", "\*_TOKEN", "\*_PASSWORD", "\*_KEY"\]'
for f in skills/core/scripts/init-config.sh skills/core/references/core.md README.md; do
  grep -q "$REDACT" "$f" || err "$f redact default differs from the canonical list"
done
grep -q '\["\*_SECRET", "\*_TOKEN", "\*_PASSWORD", "\*_KEY"\]' \
  skills/core/references/topics.md \
  || err "topics.md operations rule does not quote the redact default"
grep -q '<redacted>' skills/core/references/topics.md \
  || err "topics.md operations rule lost the <redacted> marker"
grep -q "$REDACT" templates/capstone-map-review.yml \
  || err "templates/capstone-map-review.yml redact default differs from the canonical list"

# 8. no .ps1 anywhere: the scripts are bash-only by design (see header).
#    A returning twin means someone re-created the hand-mirroring that
#    shipped silently-missing checks three times.
for f in skills/core/scripts/*.ps1; do
  [ -e "$f" ] && err "PowerShell script is back: $f (scripts are bash-only)"
done

# 9. every tracked .json parses (a stray comma in marketplace.json breaks
#    installation for every user, and no grep-based check would see it)
if [ "$IN_GIT" -eq 1 ] && command -v python3 >/dev/null 2>&1; then
  for f in $(git ls-files '*.json'); do
    # git ls-files still lists a tracked file deleted from the worktree;
    # that is a pending deletion, not a syntax error, and reporting it as
    # "invalid JSON" sends the reader hunting for a stray comma.
    [ -f "$f" ] || continue
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
  for n in ask changelog guides onboarding be-review fe-review generate sync \
         code-prefs; do
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
  for f in skills/core/scripts/init-config.sh \
           skills/core/references/core.md README.md; do
    grep -q '"index_file": "docs/capstone/00-index.md"' "$f" \
      || err "$f does not carry the docs-area index_file default"
  done
  grep -q 'Topic | File | Commit' skills/core/references/protocols/map.md \
    && err "map.md still specifies stamp columns in the index table"
  for f in skills/core/scripts/init-config.sh; do
    grep -q '00-index.md' "$f" || err "$f lost the root-DESIGN.md index migration"
    grep -q 'uiux-interview.md' "$f" || err "$f lost the design->uiux migration"
  done
else
  echo "note: dead-name check skipped (not a git checkout)"
fi

# 10d. a removed or renamed command must not be advertised in any skill
#      description. The description IS the routing signal - an agent
#      picks a command by reading it - so a dead name there is a routing
#      defect, not a typo, and 10b cannot see it (it checks wiring, and
#      a description only makes claims about wiring). Referential forms
#      only: the bare words are legitimate prose ("design a feature" is
#      one of groom's triggers, changelog.md is a real file).
DEAD_NAMES='ask|changelog|guides|onboarding|be-review|fe-review|implementation|design|generate|sync|code-prefs'
for f in skills/*/SKILL.md; do
  d=$(sed -n 's/^description: *//p' "$f")
  [ -n "$d" ] || continue
  hit=$(printf '%s' "$d" \
    | grep -Eo "\(($DEAD_NAMES)\)|use ($DEAD_NAMES)[^a-z]" | head -1)
  [ -n "$hit" ] \
    && err "$f description advertises a removed/renamed command: $hit"
done
# 10e. README's stage-by-stage prose names each stage as a bold lead-in.
#      Check 5 reads only the command table and the routing snippet, which
#      is how `**design**.` survived the uiux rename in that prose: a whole
#      paragraph describing a stage no longer reachable by that name.
hit=$(grep -Eo "^\*\*($DEAD_NAMES)\*\*" README.md | head -1)
[ -n "$hit" ] \
  && err "README prose still describes a removed/renamed stage: $hit"

# 11. every writing protocol carries its changelog pointer, the exempt
#     ones say so, and the old opt-in is gone (core.md hard rule 5 is
#     only as good as its sites)
for n in groom plan implement mockup logic uiux architecture \
         standards stack build review \
         map doctor; do
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
# 11b. the ledger's durability, shape, and bound. implement deletes each
#      feature folder on the strength of its entry, so an untracked or
#      rotated-away ledger is permanent data loss, and a rambling one is
#      unreadable at the moment it is the only copy left.
grep -q 'always committed' skills/core/references/core.md \
  || err "core.md lost the always-committed rule for changelog.md"
grep -q 'ledger is always committed' skills/core/references/core-authoring.md \
  || err "core-authoring.md does not exempt changelog.md from docs_in_git"
grep -q 'bullets only' skills/core/references/core.md \
  || err "core.md lost the bullets-only rule for changelog entries"
grep -q 'Rotation:' skills/core/references/core.md \
  || err "core.md lost the changelog rotation rule"
grep -q 'keys never leave' skills/core/references/core.md \
  || err "core.md lost the rule keeping archived changelog keys in place"
grep -q 'One writer at a time' skills/core/references/core.md \
  || err "core.md lost the single-writer note"
grep -q 'Ledger size' skills/core/references/protocols/doctor.md \
  || err "doctor.md has no ledger-size check to perform the rotation"
# 11c. the version stamp: template drift sees a section go missing, never
#      one whose meaning moved, so migrations need to know what wrote a file
for f in skills/core/references/core.md skills/core/references/core-authoring.md \
         skills/core/references/protocols/map.md; do
  grep -q 'capstone_version' "$f" \
    || err "$f does not carry the capstone_version stamp"
done

# 12. the local-only ignore list is identical in both initializers and
#     documented in core.md (hand-synced across three files); changelog.md
#     is part of the reference and must never reappear in the templates,
#     and both initializers must carry the unignore migration for it
for r in 'features/' '\*-interview.md' 'capstone.json' 'review.md' 'be-review.md' 'fe-review.md'; do
  for f in skills/core/scripts/init-config.sh; do
    grep -q "^$r$" "$f" || err "$f ignore template missing rule $r"
  done
done
for f in skills/core/scripts/init-config.sh; do
  grep -q "^changelog\.md$" "$f" && err "$f ignore template still lists changelog.md (it follows docs_in_git now)"
  grep -q "unignored: changelog.md" "$f" || err "$f lost the changelog.md unignore migration"
done
grep -q 'Local-only outputs' skills/core/references/core-authoring.md \
  || err "core-authoring.md has no Local-only outputs section"
for f in skills/core/scripts/init-config.sh; do
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

# 12c. execution is capstone's own: the two code-writing stages ask the
#      user for subagent-vs-inline and record it, and no protocol
#      invokes a superpowers skill at runtime (prose attribution in
#      groom/plan is fine; a `superpowers:<skill>` call is not)
for n in implement build; do
  grep -q 'execution: subagent | inline' "skills/core/references/protocols/$n.md" \
    || err "protocol $n.md does not record the execution mode"
  grep -q 'Ask the mode once' "skills/core/references/protocols/$n.md" \
    || err "protocol $n.md does not ask subagent-vs-inline before executing"
done
if grep -rl 'superpowers:' skills/core/references/protocols/ >/dev/null 2>&1; then
  err "a protocol invokes a superpowers skill: $(grep -rl 'superpowers:' skills/core/references/protocols/ | tr '\n' ' ')"
fi
grep -q 'superpowers' skills/core/references/core-authoring.md \
  && err "core-authoring.md still lists superpowers as an installable delegation"

# 12d. review is one command with two sides, one output file, ignored
grep -q '^# review \[backend|frontend\]' skills/core/references/protocols/review.md \
  || err "review.md H1 does not declare its backend|frontend argument"
for s in backend frontend; do
  grep -q "^## $(echo $s | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo $s | cut -c2-)\$" \
    skills/core/references/protocols/review.md \
    || grep -q "### $(echo $s | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo $s | cut -c2-)\$" \
    skills/core/references/protocols/review.md \
    || err "review.md has no $s method-source section"
done
grep -q 'docs/capstone/review\.md' skills/core/references/protocols/review.md \
  || err "review.md does not name its output file"
grep -q 'rewrites only its own section' skills/core/references/protocols/review.md \
  || err "review.md does not state that a one-sided run preserves the other side"
for f in skills/core/scripts/init-config.sh; do
  grep -q '^review\.md$' "$f" || err "$f ignore template does not cover review.md"
done
grep -q 'sole opinionated output' skills/core/references/core.md \
  || err "core.md does not name review as the sole opinionated output"

# 12e. the craft files are the method, not a fallback: no protocol may
#      route method to an installed skill, and each craft file must
#      carry its upstream attribution (Apache-2.0 and MIT both require
#      it, and both files are modified derivatives)
for n in uiux review build; do
  grep -Eq 'impeccable|design-taste|improve-codebase-architecture|codebase-design' \
    "skills/core/references/protocols/$n.md" \
    && err "protocol $n.md still routes method to an installed skill"
done
grep -q 'Delegation installs' skills/core/references/core-authoring.md \
  && err "core-authoring.md still carries the Delegation installs section"
for f in uiux-craft arch-craft; do
  grep -q '^\*\*Attribution\.\*\*' "skills/core/references/$f.md" \
    || err "$f.md has no Attribution block"
  grep -q 'This file is the method' "skills/core/references/$f.md" \
    || err "$f.md does not declare itself the method"
done
grep -q 'Apache License 2.0' skills/core/references/uiux-craft.md \
  || err "uiux-craft.md does not name impeccable's Apache-2.0 licence"
grep -q 'Copyright (c) 2026 Leonxlnx' skills/core/references/uiux-craft.md \
  || err "uiux-craft.md does not carry taste-skill's MIT copyright line"
grep -q '© Matt Pocock' skills/core/references/arch-craft.md \
  || err "arch-craft.md lost its MIT copyright line"
# logic-craft is original work, so no attribution block; it must still
# declare itself the method and be walked by the protocol it serves,
# or logic silently goes back to stopping when nothing comes to mind
grep -q 'This file is the method' skills/core/references/logic-craft.md \
  || err "logic-craft.md does not declare itself the method"
grep -q 'logic-craft.md' skills/core/references/protocols/logic.md \
  || err "logic.md does not wire logic-craft.md"
grep -q 'Dimensions not in play' skills/core/references/protocols/logic.md \
  || err "logic.md lost the dimension-coverage record in its scenario files"

# 12f. design/ gets the same generate+sync extraction logic/ has: a
#      brownfield repo must end up with a frontend design record, not
#      only a business-logic one
grep -q '\*\*Design extraction\*\*' skills/core/references/protocols/map.md \
  || err "map.md has no design-extraction step"
grep -q '\*\*Design coverage\.\*\*' skills/core/references/protocols/map.md \
  || err "map.md refresh has no design-coverage step"
grep -q '\*\*Design coverage\*\*' skills/core/references/protocols/map.md \
  || err "map check has no design-coverage report"
grep -q 'Invoked by `map`' skills/core/references/protocols/uiux.md \
  || err "uiux.md has no headless extraction block for map"
grep -q 'Invoked by `map`' skills/core/references/protocols/logic.md \
  || err "logic.md lost its headless extraction block"
# extraction must never clobber a committed design
grep -q 'never touched here' skills/core/references/protocols/map.md \
  || err "map.md does not protect interview-derived uiux/ files from extraction"

# 12g. the machine verdict lines are a contract. map.md promises both;
#      the gate template (script half, no API key) greps only MAP CHECK:
#      and the review template (model half) greps only MAP REVIEW:, so a
#      reworded line, or a template reading the other half's line, would
#      silently turn CI green or red.
for s in 'MAP CHECK: current' 'MAP CHECK: stale' 'MAP REVIEW: clean' 'MAP REVIEW: <N> findings'; do
  grep -qF "$s" skills/core/references/protocols/map.md \
    || err "map.md lost the verdict line: $s"
done
grep -q 'scripts/map-check\.sh' skills/core/references/protocols/map.md \
  || err "map.md check section does not run map-check.sh"
# the protocol promises the Site test the script performs
grep -q 'ls-files --error-unmatch' skills/core/scripts/map-check.sh \
  || err "map-check.sh does not verify Site paths with git ls-files"
grep -q 'ls-files --error-unmatch' skills/core/references/protocols/map.md \
  || err "map.md check part 8 does not name the Site test"
CHK=templates/capstone-map-check.yml
REV=templates/capstone-map-review.yml
[ -f "$CHK" ] || err "$CHK is missing"
[ -f "$REV" ] || err "$REV is missing"
grep -q 'MAP CHECK: ' "$CHK" || err "$CHK does not parse the MAP CHECK verdict line"
grep -q 'MAP REVIEW' "$CHK" && err "$CHK must never read the MAP REVIEW line"
grep -q 'map-check\.sh' "$CHK" || err "$CHK does not run map-check.sh"
grep -q 'fetch-depth: 0' "$CHK" || err "$CHK lost fetch-depth: 0 (stamps must be reachable)"
grep -q 'ANTHROPIC_API_KEY' "$CHK" && err "$CHK needs no API key (the gate is a script)"
grep -q 'capstone:map check' "$CHK" && err "$CHK still invokes the model"
grep -q 'MAP REVIEW: ' "$REV" || err "$REV does not parse the MAP REVIEW verdict line"
grep -q 'MAP CHECK' "$REV" && err "$REV must never read the MAP CHECK line"
grep -q 'capstone:map check' "$REV" || err "$REV does not invoke map check"
grep -q 'ANTHROPIC_API_KEY' "$REV" || err "$REV does not pass the API key"
grep -q '^  schedule:' "$REV" || err "$REV has no schedule trigger"
grep -q 'workflow_dispatch' "$REV" || err "$REV has no workflow_dispatch trigger"
for t in capstone-map-check capstone-map-review; do
  grep -q "templates/$t\.yml" README.md || err "README does not point at templates/$t.yml"
  grep -q "templates/$t\.yml" docs/commands.md || err "docs/commands.md does not point at templates/$t.yml"
done
grep -q 'Upgrading from 6.1' README.md \
  || err "README lost the 'Upgrading from 6.1' note (the gate template changed shape)"
# the gate clones the release tag that ships the script; the pin must
# move with the manifests (check 2's version) or every user runs an old
# script against new templates
V=$(printf '%s\n' "$UNIQ" | grep '.' | head -1)
grep -q -- "--branch v$V " "$CHK" \
  || err "$CHK does not pin --branch v$V (the manifest version)"

# 12h. generate and sync merged into map: one verb, because the branch is
#      readable off disk. Both old names must stay unroutable, and map must
#      still carry both halves - the builder and the selector.
for h in 'Phase 1 - inline recon' 'Phase 2 - deep-dive' 'Phase 3 - compose' \
         'Refresh - rewrite only what drifted' 'check - the read-only trust report'; do
  grep -q "^## $h" skills/core/references/protocols/map.md \
    || err "map.md lost section: $h"
done

# 12i. TDD + YAGNI is the centre of gravity, not a plan-time footnote.
#      The stages that DECIDE what will exist (architecture, stack) must
#      climb the ladder too: a layer agreed at design time and a
#      dependency agreed at stack time are code no later rung can stop.
for n in architecture stack plan build implement review standards; do
  grep -q 'code-craft\.md' "skills/core/references/protocols/$n.md" \
    || err "protocol $n.md does not read code-craft.md (TDD + YAGNI)"
done
grep -q 'Climb the ladder first' skills/core/references/protocols/stack.md \
  || err "stack.md lost its ladder gate before vendor research"
grep -q 'YAGNI bounds the design' skills/core/references/protocols/architecture.md \
  || err "architecture.md lost the rule that YAGNI bounds the design"
# the override is deliberate or it is not an override
grep -q 'deliberate and recorded' skills/core/references/code-craft.md \
  || err "code-craft.md lost the explicit-override precedence rule"
grep -q 'Overriding the craft file' skills/core/references/protocols/standards.md \
  || err "standards.md has no place to record a craft-file override"
# the ceiling marker names itself; ponytail is not a bundled skill
grep -q 'ponytail:' skills/core/references/code-craft.md \
  && err "code-craft.md still uses the ponytail: marker (use ceiling:)"

# 12j. interviews challenge a bad decision, twice, then defer. The cap
#      is the load-bearing half: without it a stage relitigates, and
#      capstone's rule is that recorded user decisions win.
grep -q '^## Pushback' skills/core/references/core.md \
  || err "core.md lost the interview Pushback rule"
grep -q 'never more than' skills/core/references/core.md \
  || err "core.md's Pushback rule lost its two-round cap"

# 12k. interviews are local working state. Final outputs must survive a
#      fresh clone, so authoring instructions cannot make them cite an
#      interview file or question number.
grep -q 'Final outputs never name or cite interview files' \
  skills/core/references/core.md \
  || err "core.md lost final-output authority after formalization"
grep -q 'Final outputs must stand alone' \
  skills/core/references/core-authoring.md \
  || err "core-authoring.md lost the standalone-output rule"
for f in README.md docs/*.md skills/core/references/*.md \
         skills/core/references/protocols/*.md; do
  hit=$(awk 'BEGIN { ORS="" } /^$/ { print "\n"; next } { print $0 " " } END { print "\n" }' "$f" \
    | grep -E 'interview\.md §Q|traceable to (its|a|an) `?§Q|`§Q` entries.*implements|→ `§Q`' \
    | head -1)
  [ -n "$hit" ] \
    && err "$f instructs a final output to expose interview provenance: $hit"
done
grep -q 'Pushback rule' skills/core/references/interview.md \
  || err "interview.md conduct rules do not point at core.md's Pushback rule"

# 12k. README's jump-to nav must resolve. GitHub renders a dead anchor
#      without complaint, so a renamed section breaks navigation
#      silently - the same class as a stale SKILL.md description.
#      Anchors come in two shapes: markdown ](#...) links, and the
#      README header's HTML <a href="#..."> row (the branded nav).
for doc in README.md docs/commands.md; do
  HEADS=$(grep -E '^#{2,3} ' "$doc" \
    | sed -e 's/^#\{2,3\} //' -e 's/[`*_]//g' \
          -e 's/[^[:alnum:][:space:]-]//g' \
          -e 's/[[:space:]]\{1,\}/-/g' \
    | tr '[:upper:]' '[:lower:]')
  ANCHORS=$( { grep -o '](#[^)]*)' "$doc" | sed -e 's/](#//' -e 's/)//'
               grep -o 'href="#[^"]*"' "$doc" | sed -e 's/href="#//' -e 's/"//'; } )
  for a in $ANCHORS; do
    printf '%s\n' "$HEADS" | grep -qx "$a" \
      || err "$doc jump-to link #$a matches no heading"
  done
  { grep -q '^\*\*Jump to:\*\*' "$doc" || grep -q 'href="#' "$doc"; } \
    || err "$doc lost its jump-to nav"
done

# 12l. the licence is stated in seven places and must agree. Apache-2.0
#      is load-bearing here: NOTICE is what makes a derivative point
#      back at this repo (section 4(d)), so a manifest still claiming MIT
#      would hand someone the wrong terms.
grep -q 'Apache License' LICENSE || err "LICENSE is not the Apache License"
grep -q 'Copyright 2026 Gent Bajko' LICENSE \
  || err "LICENSE appendix still has the placeholder copyright line"
[ -f NOTICE ] || err "NOTICE is missing (Apache-2.0 section 4(d) attribution)"
grep -q 'github.com/GentBajko/capstone' NOTICE \
  || err "NOTICE does not name the repository derivatives must reference"
for f in .claude-plugin/plugin.json .codex-plugin/plugin.json \
         .cursor-plugin/plugin.json .kimi-plugin/plugin.json; do
  grep -q '"license": "Apache-2.0"' "$f" \
    || err "$f does not declare license Apache-2.0"
done
# the branded README states the licence via the shield badge's alt text
grep -q 'Apache-2.0 licensed' README.md \
  || err "README does not state the project licence as Apache-2.0"
# every vendored work keeps its own notice
for w in 'impeccable' 'design-taste-frontend' 'mattpocock/skills'; do
  grep -q "$w" NOTICE || err "NOTICE lost the attribution for $w"
done

# 12m. every SKILL.md frontmatter must be valid YAML. Installers parse
#      it: `gh skill install` refused a skill outright with "invalid
#      frontmatter YAML" and left an empty directory behind, so a plain
#      scalar containing ": " breaks installation while every grep-based
#      check here still passes. Prefer ruby (macOS ships psych); fall
#      back to python's yaml, then to a targeted scan for the traps.
for f in skills/*/SKILL.md; do
  fm=$(sed -n '/^---$/,/^---$/p' "$f" | sed '1d;$d')
  if command -v ruby >/dev/null 2>&1; then
    printf '%s\n' "$fm" | ruby -ryaml -e 'YAML.safe_load(STDIN.read)' >/dev/null 2>&1 \
      || err "$f frontmatter is not valid YAML"
  elif command -v python3 >/dev/null 2>&1 \
       && python3 -c 'import yaml' >/dev/null 2>&1; then
    printf '%s\n' "$fm" | python3 -c 'import yaml,sys; yaml.safe_load(sys.stdin)' >/dev/null 2>&1 \
      || err "$f frontmatter is not valid YAML"
  else
    printf '%s\n' "$fm" | grep -q ': .*: ' \
      && err "$f frontmatter has a plain scalar containing \": \" (breaks YAML)"
  fi
done

# 12n. the payload-section contract: topics.md defines the `### <Name>`
#      sections quarry check compares, map.md names them at compose
#      time, map-check.sh enforces them in the schema pass, and
#      docs/commands.md tells the reader what reads them
grep -q '^\*\*Payload sections\.\*\*' skills/core/references/topics.md \
  || err "topics.md lost the Payload sections paragraph"
grep -q 'Payload sections' skills/core/references/protocols/map.md \
  || err "map.md does not mention the payload sections"
grep -q 'payload section' skills/core/scripts/map-check.sh \
  || err "map-check.sh lost the payload-section check"
grep -q 'quarry check' docs/commands.md \
  || err "docs/commands.md does not mention quarry check"

# 13. bash syntax of every .sh
for s in skills/core/scripts/*.sh; do
  bash -n "$s" 2>/dev/null || err "bash syntax error in $s"
done


# 14. the pipeline order is spelled identically everywhere it appears
PIPE='mockup -> logic -> uiux -> architecture -> standards -> stack -> build'
for f in skills/core/scripts/help.sh skills/start/SKILL.md; do
  grep -qF "$PIPE" "$f" || err "$f missing the pipeline-order string"
done
grep -qF 'mockup → logic → uiux → architecture → standards → stack → build' README.md \
  || err "README.md missing the pipeline-order string"

# 15. the required-headings list is embedded in map-check.sh (the gate
#     runs with no model, so it cannot read topics.md's prose) and must
#     equal topics.md's `## ...` bullets, the way check 14 pins the
#     pipeline string. Compared sorted so section order is free.
EXPECT=$(LC_ALL=C awk '
  /^## [a-z-]+\.md$/ { if (t != "") print t ": " h; t = $2; sub(/\.md$/, "", t); h = ""; next }
  /^- `## / { s = $0; sub(/^- `## /, "", s); sub(/`.*/, "", s); h = (h == "" ? s : h "|" s) }
  END { if (t != "") print t ": " h }' skills/core/references/topics.md | LC_ALL=C sort)
GOT=$(bash skills/core/scripts/map-check.sh --headings | LC_ALL=C sort)
[ "$EXPECT" = "$GOT" ] || err "map-check.sh --headings disagrees with topics.md
expected:
$EXPECT
got:
$GOT"
# 15b. the content_hash recipe is spelled once and the same in the two
#      protocol files and the script; ls-tree does not glob, so the old
#      recipe hashed nothing and must not come back anywhere
for f in skills/core/references/core.md skills/core/references/protocols/map.md \
         skills/core/scripts/map-check.sh; do
  grep -q 'git ls-files -s --full-name -- ' "$f" \
    || err "$f lost the content_hash recipe (git ls-files -s --full-name)"
  grep -q 'ls-tree -r HEAD -- ' "$f" \
    && err "$f still carries the ls-tree content_hash recipe (it does not glob)"
done

# 16. map-check.sh is the CI gate: its flags, exit codes, verdict line
#     and the P8 secret patterns are a contract with the templates, the
#     docs, and quarry's src/secrets.rs (spelled identically there).
MC=skills/core/scripts/map-check.sh
[ -f "$MC" ] || err "$MC is missing"
bash "$MC" --headings >/dev/null 2>&1 || err "$MC --headings failed"
bash "$MC" --patterns >/dev/null 2>&1 || err "$MC --patterns failed"
bash "$MC" --no-such-flag >/dev/null 2>&1; [ $? -eq 2 ] || err "$MC unknown flag does not exit 2"
for n in aws-access-key github-token slack-token stripe-key google-api-key private-key; do
  bash "$MC" --patterns | grep -q "^$n	" || err "$MC --patterns lacks $n"
  grep -q "\`$n\`" docs/commands.md || err "docs/commands.md does not list secret pattern $n"
done
for f in skills/core/scripts/help.sh docs/commands.md README.md skills/core/SKILL.md \
         skills/core/references/protocols/groom.md skills/core/references/protocols/doctor.md; do
  grep -q 'map-check\.sh' "$f" || err "$f does not name map-check.sh"
done
# 16b. smoke runs. First outside git (headings, generated_date, secrets,
#      the verdict and the exit code), then inside a throwaway git repo
#      for every part-1 branch and the Site test. The global config is
#      pointed at an empty folder so the machine's own index_file cannot
#      leak into the fixture. Every case asserts the verdict line and the
#      exit code. The secret literal is split across printf arguments so
#      this file never contains a matching string. Every sandbox lives
#      under a directory named `g[1]`, so an unquoted path prefix in the
#      script would be read as a glob and mangle displayed paths and the
#      skip list.
MCABS="$PWD/$MC"
T=$(mktemp -d 2>/dev/null || mktemp -d -t capstone)
G="$T/g[1]"
mkdir -p "$T/global" "$G/ok/docs/changelog.d" "$G/bad/docs" "$G/crlf/docs" "$G/noidx/docs"
mc_run() { # label expected_rc expected_verdict dir [args...]; sets MC_OUT
  local label="$1" rc_want="$2" want="$3" dir="$4" rc; shift 4
  MC_OUT=$(cd "$dir" && CAPSTONE_GLOBAL_DIR="$T/global" bash "$MCABS" "$@" 2>&1); rc=$?
  [ "$rc" -eq "$rc_want" ] || err "map-check.sh $label exited $rc, wanted $rc_want"
  printf '%s\n' "$MC_OUT" | tail -1 | grep -qx "$want" \
    || err "map-check.sh $label verdict: $(printf '%s\n' "$MC_OUT" | tail -1), wanted: $want"
}
mc_row() { printf '%s\n' "$MC_OUT" | grep -q "$1" || err "map-check.sh $2: no row matching $1"; }
mc_index() { printf '# i\n\n| Topic | File |\n| --- | --- |\n| glossary | [08-glossary.md](08-glossary.md) |\n' > "$1/00-index.md"; }
mc_gloss() { # dir stamp hash version [extra frontmatter line]
  printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\npaths_covered:\n  - ":(top)src/**"\n%s---\n# g\n\n## Concepts\n\nnone\n' \
    "$2" "$4" "$3" "${5:-}" > "$1/08-glossary.md"
}
mc_index "$G/ok/docs"
printf -- '---\ngenerated_date: 2026-01-01\n---\n# g\n\n## Concepts\n\nnone\n' > "$G/ok/docs/08-glossary.md"
# the ledger is skipped entirely, secrets included; an unfolded fragment
# is listed but never counted
printf -- '- AKIA%s pasted into the ledger\n' "ABCDEFGHIJKLMNOP" > "$G/ok/docs/changelog.md"
printf 'key: map/all@abc123def456\n' > "$G/ok/docs/changelog.d/2026-01-01-map-all.md"
cp "$G/ok/docs/00-index.md" "$G/bad/docs/00-index.md"
printf -- '---\ngenerated_date: 2026-01-01\n---\n# g\n\nAKIA%s\n' "ABCDEFGHIJKLMNOP" > "$G/bad/docs/08-glossary.md"
mc_run 'non-git clean' 0 'MAP CHECK: current' "$G/ok" docs
mc_row '^- changelog.d/2026-01-01-map-all.md: key map/all@abc123def456$' 'non-git clean'
mc_row '^unfolded fragments: 1 ' 'non-git clean'
mc_run 'non-git stale' 1 'MAP CHECK: stale (2 findings)' "$G/bad" docs
mc_row '| docs/08-glossary.md | - | ## Concepts | - | secret: aws-access-key |' 'non-git stale'
# a CRLF checkout reads as LF: frontmatter fences and headings still match
mc_index "$G/crlf/docs"
printf -- '---\r\ngenerated_date: 2026-01-01\r\n---\r\n# g\r\n\r\n## Concepts\r\n\r\nnone\r\n' > "$G/crlf/docs/08-glossary.md"
mc_run 'non-git crlf' 0 'MAP CHECK: current' "$G/crlf" docs
# outside git the missing-index path is shown as given
mc_run 'non-git missing index' 1 'MAP CHECK: stale (1 findings)' "$G/noidx" docs
mc_row '^no index at docs/00-index.md$' 'non-git missing index'
if command -v git >/dev/null 2>&1; then
  # the sandbox must not inherit the developer's git config, the way
  # CAPSTONE_GLOBAL_DIR keeps the machine's capstone.json out: with
  # commit.gpgsign on, or a global hooks path that rejects the commit,
  # `git commit` fails, SHA and H come back empty, and every part-1 case
  # reports a verdict mismatch instead of the real cause. GIT_CONFIG_*
  # covers git 2.32 and later; the empty template and the per-command
  # -c cover older builds.
  mkdir -p "$T/gittemplate"
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_CONFIG_NOSYSTEM=1
  GC='-c commit.gpgsign=false'
  S="$G/repo"; mkdir -p "$S/src" "$S/docs/capstone"
  git -C "$S" init -q --template="$T/gittemplate" 2>/dev/null
  git -C "$S" config user.email lint@capstone; git -C "$S" config user.name lint
  printf 'fn main(){}\n' > "$S/src/main.rs"
  git -C "$S" add src; git -C "$S" $GC commit -qm one
  git -C "$S" rev-parse --verify -q HEAD >/dev/null \
    || err "map-check.sh git fixture: the sandbox commit failed, so every case below is unreliable"
  SHA=$(git -C "$S" rev-parse --short=12 HEAD)
  H=$(git -C "$S" ls-files -s --full-name -- ':(top)src/**' | git hash-object --stdin | cut -c1-12)
  MANIFEST_V=$(printf '%s\n' "$UNIQ" | grep '.' | head -1)
  mc_index "$S/docs/capstone"; mc_gloss "$S/docs/capstone" "$SHA" "$H" "$MANIFEST_V"
  git -C "$S" add docs; git -C "$S" $GC commit -qm docs
  mc_run 'git current' 0 'MAP CHECK: current' "$S"
  mc_row "| docs/capstone/08-glossary.md | $SHA | $MANIFEST_V | 0 | current |" 'git current'
  printf 'x\n' >> "$S/src/main.rs"
  mc_run 'git working-tree drift' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| 1 | stale |' 'git working-tree drift'
  git -C "$S" checkout -q -- src/main.rs
  touch "$S/src/new.rs"
  mc_run 'git untracked file' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| 1 | stale |' 'git untracked file'
  rm "$S/src/new.rs"
  # a stamp no object carries: the squash-merge case
  mc_gloss "$S/docs/capstone" ffffffffffff "$H" "$MANIFEST_V"
  mc_run 'unreachable stamp, hash matches' 0 'MAP CHECK: current' "$S"
  mc_gloss "$S/docs/capstone" ffffffffffff 000000000000 "$MANIFEST_V"
  mc_run 'unreachable stamp, hash differs' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| - | stale |' 'unreachable stamp, hash differs'
  mc_gloss "$S/docs/capstone" ffffffffffff e69de29bb2d1 "$MANIFEST_V"
  mc_run 'legacy empty hash' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| stamp unreachable |' 'legacy empty hash'
  # no reachable stamp and no version: the missing stamp is the verdict,
  # ahead of the version gap (map.md's part-1 order)
  mc_gloss "$S/docs/capstone" ffffffffffff e69de29bb2d1 ""
  mc_run 'unreachable stamp without a version' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| ffffffffffff | - | - | stamp unreachable |' 'unreachable stamp without a version'
  mc_gloss "$S/docs/capstone" "$SHA" "$H" 5.2.1
  mc_run 'older capstone' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| written by an older capstone |' 'older capstone'
  mc_gloss "$S/docs/capstone" "$SHA" "$H" "$MANIFEST_V" 'mode: prescriptive
'
  mc_run 'prescriptive with tracked source' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| prescriptive, pending first observation |' 'prescriptive with tracked source'
  mc_gloss "$S/docs/capstone" "$SHA" "$H" "$MANIFEST_V"
  mv "$S/docs/capstone/00-index.md" "$S/docs/capstone/INDEX.md"
  mc_run 'missing index' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '^no index at docs/capstone/00-index.md$' 'missing index'
  printf '{ "index_file": "docs/capstone/INDEX.md" }\n' > "$S/docs/capstone/capstone.json"
  mc_run 'config index_file' 0 'MAP CHECK: current' "$S"
  rm "$S/docs/capstone/capstone.json"
  mv "$S/docs/capstone/INDEX.md" "$S/docs/capstone/00-index.md"
  # a project index_file one level down is legal: the capstone.json that
  # names it sits inside the docs area it configures
  mkdir -p "$S/docs/capstone/index"
  mv "$S/docs/capstone/00-index.md" "$S/docs/capstone/index/00-index.md"
  printf '{ "index_file": "docs/capstone/index/00-index.md" }\n' > "$S/docs/capstone/capstone.json"
  mc_run 'nested project index_file' 0 'MAP CHECK: current' "$S"
  # and one that names no file is reported at that path, not swapped for
  # <docs_dir>/00-index.md
  printf '{ "index_file": "docs/capstone/index/NOPE.md" }\n' > "$S/docs/capstone/capstone.json"
  mc_run 'nested project index_file names no file' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '^no index at docs/capstone/index/NOPE.md$' 'nested project index_file names no file'
  rm "$S/docs/capstone/capstone.json"
  mv "$S/docs/capstone/index/00-index.md" "$S/docs/capstone/00-index.md"
  rmdir "$S/docs/capstone/index"
  printf '{ "index_file": "docs/other/00-index.md" }\n' > "$T/global/capstone.json"
  mc_run 'global index_file outside the docs dir' 0 'MAP CHECK: current' "$S"
  rm "$T/global/capstone.json"
  # the stock global index_file names a file one level down; a project
  # whose docs area is `docs` keeps its own docs/00-index.md
  printf '{ "index_file": "docs/capstone/00-index.md" }\n' > "$T/global/capstone.json"
  mc_run 'global index_file in a subdirectory' 1 'MAP CHECK: stale (1 findings)' "$S" docs
  mc_row '^no index at docs/00-index.md$' 'global index_file in a subdirectory'
  rm "$T/global/capstone.json"
  mkdir -p "$S/docs/two"; mc_index "$S/docs/two"
  mc_gloss "$S/docs/two" ffffffffffff 000000000000 "$MANIFEST_V"
  touch "$S/src/new.rs"
  mc_run 'two docs dirs' 1 'MAP CHECK: stale (2 findings)' "$S" docs/capstone docs/two
  [ "$(printf '%s\n' "$MC_OUT" | grep -c '^# map check:')" -eq 2 ] || err "map-check.sh two docs dirs: not two sections"
  [ "$(printf '%s\n' "$MC_OUT" | grep -c '^MAP CHECK:')" -eq 1 ] || err "map-check.sh two docs dirs: not exactly one verdict line"
  rm "$S/src/new.rs"; rm -r "$S/docs/two"
  # Site cells: tracked, an escaped pipe in an earlier cell, a link cell
  # with a :from-to range, a fenced decoy. Every row carries its
  # `### <Name>` payload section, one of them by the version-suffix form
  # (`### ingest (v2)`), so the site cases below count sites only.
  mc_iface() { # dir: the interfaces fixture, payload sections included
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
      printf '# Interfaces\n\n## Produces\n\n| Kind | Name | To | Site |\n| --- | --- | --- | --- |\n| http | GET /a | other | `src/main.rs:12` |\n'
      printf '%s\n\n' '| http | GET /b \| GET /c | other | `src/main.rs:1` |'
      printf '### GET /a\n\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
      printf '%s\n\n' '### GET /b | GET /c'
      printf '## Consumes\n\n| Kind | Name | From | Site |\n| --- | --- | --- | --- |\n| sqs | ingest | other | [src/main.rs](../../src/main.rs):57-60 |\n\n'
      printf '### ingest (v2)\n\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
      printf '```markdown\n| Kind | Name | To | Site |\n| --- | --- | --- | --- |\n| http | decoy | other | `src/decoy.rs:1` |\n```\n'
    } > "$1/09-interfaces.md"
  }
  mc_iface "$S/docs/capstone"
  git -C "$S" add docs; git -C "$S" $GC commit -qm iface
  mc_run 'tracked sites' 0 'MAP CHECK: current' "$S"
  sed 's|`src/main.rs:12`|`src/gone.rs:12`|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'untracked site' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | - | site src/gone.rs:12 | - |' 'untracked site'
  printf '%s\n' "$MC_OUT" | grep -q 'decoy' && err "map-check.sh read the fenced decoy table"
  # a Site cell has to name one file. `ls-files --error-unmatch` on its
  # own accepts a tracked directory and a wildcard, both of which name
  # none, and quarry's blob-set test rejects them.
  cp "$S/docs/capstone/09-interfaces.md" "$T/iface-gone.md"
  sed 's|`src/gone.rs:12`|`src`|' "$T/iface-gone.md" > "$S/docs/capstone/09-interfaces.md"
  mc_run 'site names a directory' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | - | site src | - |' 'site names a directory'
  sed 's|`src/gone.rs:12`|`src/*.rs`|' "$T/iface-gone.md" > "$S/docs/capstone/09-interfaces.md"
  mc_run 'site names a glob' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | - | site src/[*][.]rs | - |' 'site names a glob'
  cp "$T/iface-gone.md" "$S/docs/capstone/09-interfaces.md"
  sed '3a\
mode: prescriptive' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'prescriptive page skips sites' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | .* | prescriptive, pending first observation |' 'prescriptive page skips sites'
  printf '%s\n' "$MC_OUT" | grep -q 'site src/gone.rs' && err "map-check.sh verified sites on a prescriptive page"
  # payload sections (topics.md): a Produces row whose `### <Name>`
  # section is gone is one finding in the missing-headings column, and
  # the covered page passes with the version-suffix heading matching
  mc_iface "$S/docs/capstone"
  mc_run 'payload sections covered' 0 'MAP CHECK: current' "$S"
  grep -v '^### GET /a$' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'missing payload section' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | ### GET /a | - | - |' 'missing payload section'
  # quarry's normalize_heading strips no backticks and its heading_of
  # demands a space after the hashes, so a backticked heading and a
  # tabbed one are both rows without a payload table there and findings
  # here. topics.md says to write the heading without backticks.
  mc_iface "$S/docs/capstone"
  sed 's|^### GET /a$|### `GET /a`|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'backticked payload heading' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | ### GET /a | - | - |' 'backticked payload heading'
  MC_TAB=$(printf '\t')
  mc_iface "$S/docs/capstone"
  sed "s|^### GET /a\$|###${MC_TAB}GET /a|" "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'tabbed payload heading' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | ### GET /a | - | - |' 'tabbed payload heading'
  # the same sections written tight: no blank line before or after a
  # payload heading, which GFM allows. The heading has to close the edge
  # table, or the `| Field | Type | Required |` rows under it read as more
  # edge rows and every Type and value cell becomes a missing section.
  # The headings here also differ in case from their `Name` cell and
  # escape a pipe the way the cell does; both still match.
  mc_iface_tight() { # dir [extra Produces row]
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
      printf '# Interfaces\n\n## Produces\n\n| Kind | Name | To | Site |\n| --- | --- | --- | --- |\n| http | GET /a | other | `src/main.rs:12` |\n'
      printf '%s\n' '| http | GET /b \| GET /c | other | `src/main.rs:1` |'
      [ -n "${2:-}" ] && printf '%s\n' "$2"
      printf '### get /a\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n'
      printf '%s\n' '### GET /b | GET /c'
      printf '| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n'
      printf '## Consumes\n| Kind | Name | From | Site |\n| --- | --- | --- | --- |\n| sqs | ingest | other | `src/main.rs:1` |\n'
      printf '### ingest (v2)\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n'
    } > "$1/09-interfaces.md"
  }
  mc_iface_tight "$S/docs/capstone"
  mc_run 'tight payload sections' 0 'MAP CHECK: current' "$S"
  # and a row with no section at all is still the one finding it was
  mc_iface_tight "$S/docs/capstone" '| http | miss | other | `src/main.rs:1` |'
  mc_run 'tight page, uncovered row' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | ### miss | - | - |' 'tight page, uncovered row'
  # the non-markdown sweep: a tracked .env.example beside the chapters
  # is secret-scanned, an untracked one is not (it never ships), and a
  # skipped path stays skipped whatever it holds
  mc_iface_tight "$S/docs/capstone"
  mc_run 'tight payload sections again' 0 'MAP CHECK: current' "$S"
  printf -- 'AWS_ACCESS_KEY_ID=AKIA%s\n' "ABCDEFGHIJKLMNOP" > "$S/docs/capstone/scratch.env"
  mc_run 'untracked non-markdown file' 0 'MAP CHECK: current' "$S"
  mv "$S/docs/capstone/scratch.env" "$S/docs/capstone/.env.example"
  git -C "$S" add docs/capstone/.env.example
  mc_run 'tracked non-markdown file' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/.env.example | - | - | - | secret: aws-access-key |' 'tracked non-markdown file'
  MC_NEEDLE=$(printf 'AKIA%s' "ABCDEFGHIJKLMNOP")
  printf '%s\n' "$MC_OUT" | grep -qF "$MC_NEEDLE" && err "map-check.sh printed the matched secret"
  git -C "$S" rm -q --cached docs/capstone/.env.example
  rm "$S/docs/capstone/.env.example"
  # a tracked name that is not plain ASCII. Plain `git ls-files` prints
  # it C-quoted (`"uni-\303\251.env"`), no file of that name exists, and
  # the sweep would drop a shipped credential without a word; the
  # NUL-delimited read keeps the bytes. The name is built with printf so
  # this file stays ASCII.
  MC_UNI=$(printf 'uni-\303\251.env')
  printf -- 'AWS_ACCESS_KEY_ID=AKIA%s\n' "ABCDEFGHIJKLMNOP" > "$S/docs/capstone/$MC_UNI"
  git -C "$S" add "docs/capstone/$MC_UNI"
  mc_run 'tracked non-ascii filename' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row "| docs/capstone/$MC_UNI | - | - | - | secret: aws-access-key |" 'tracked non-ascii filename'
  git -C "$S" rm -q --cached "docs/capstone/$MC_UNI"
  rm "$S/docs/capstone/$MC_UNI"
  printf -- '{ "note": "AKIA%s" }\n' "ABCDEFGHIJKLMNOP" > "$S/docs/capstone/capstone.json"
  git -C "$S" add docs/capstone/capstone.json
  mc_run 'skipped non-markdown file' 0 'MAP CHECK: current' "$S"
  git -C "$S" rm -q --cached docs/capstone/capstone.json
  rm "$S/docs/capstone/capstone.json"
else
  echo "note: map-check.sh git fixture skipped (no git)"
fi
rm -rf "$T"

# 17. the secret-shape list is one list: map-check.sh's embedded table
#     must equal the table map.md documents, name and pattern, in order.
#     The gate greps with the script's copy and a reader repairs against
#     map.md's, so a shape added to one and not the other is a shape the
#     docs promise and the gate never looks for. The markdown cell
#     escapes | as \|; that is stripped before comparing. The doc table
#     is the |-prefixed lines between the `Secret-shaped strings` anchor
#     and the next blank line, so the bullet and its table stay
#     contiguous.
LS_TAB=$(printf '\t')
SCRIPT_PATTERNS=$(bash skills/core/scripts/map-check.sh --patterns 2>/dev/null)
DOC_PATTERNS=$(sed -n '/Secret-shaped strings/,/^$/p' \
    skills/core/references/protocols/map.md \
  | sed -n "s/^ *| \([a-z-]*\) | \`\(.*\)\` |\$/\\1$LS_TAB\\2/p" \
  | sed 's/\\|/|/g')
[ -n "$SCRIPT_PATTERNS" ] || err "map-check.sh --patterns prints nothing"
[ "$(printf '%s\n' "$SCRIPT_PATTERNS" | grep -c '.')" -eq 6 ] \
  || err "map-check.sh --patterns does not print exactly six shapes"
[ "$SCRIPT_PATTERNS" = "$DOC_PATTERNS" ] \
  || err "secret-shape table differs between map-check.sh and map.md
script:
$SCRIPT_PATTERNS
map.md:
$DOC_PATTERNS"

[ "$FAIL" -eq 0 ] && echo "lint-sync: all invariants hold" || echo "lint-sync: FAILURES above"
exit $FAIL
