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
         standards stack build review retro \
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
#     and both initializers must carry the unignore migration for it.
#     capstone.json left this list in 6.3 and is asserted absent by
#     check 19, with its own migration.
for r in 'features/' '\*-interview.md' 'review.md' 'be-review.md' 'fe-review.md'; do
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
# the script under test. One case below points this at a copy with no
# schema.txt beside it, so set it back after.
MC_BIN="$MCABS"
T=$(mktemp -d 2>/dev/null || mktemp -d -t capstone)
G="$T/g[1]"
mkdir -p "$T/global" "$G/ok/docs/changelog.d" "$G/bad/docs" "$G/crlf/docs" "$G/noidx/docs"
mc_run() { # label expected_rc expected_verdict dir [args...]; sets MC_OUT
  local label="$1" rc_want="$2" want="$3" dir="$4" rc; shift 4
  MC_OUT=$(cd "$dir" && CAPSTONE_GLOBAL_DIR="$T/global" bash "$MC_BIN" "$@" 2>&1); rc=$?
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
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\nknown_as: []\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
      printf '# Interfaces\n\n## Produces\n\n| Kind | Name | To | Site |\n| --- | --- | --- | --- |\n| http | GET /a | other | `src/main.rs:12` |\n'
      printf '%s\n\n' '| http | GET /b \| GET /c | other | `src/main.rs:1` |'
      printf '### GET /a\n\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
      printf '%s\n\n' '### GET /b | GET /c'
      printf '| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
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
  # the frontmatter edges block (topics.md): it is what map writes and
  # what quarry reads, so the pass reads it and falls back to the
  # tables only where a page has none. Sites, payload sections and
  # schema references are all checked off it, and `to`/`from` are
  # never read at all. The models chapter beside it is what a `schema`
  # and a `Model:` line resolve against.
  mc_models() { # dir: a models chapter carrying one ### Record entity
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
      printf '# Models\n\n## Entities\n\nnone\n\n## Fields and types\n\n'
      printf '### Record\n\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
      printf '## Relationships\n\nnone\n\n## Boundaries\n\nnone\n\n## Validation\n\nnone\n\n## Schema\n\nnone\n'
    } > "$1/02-models.md"
  }
  mc_iface_fm() { # dir [extra produces row]: the edges-block form
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\nknown_as: []\nedges:\n  produces:\n' "$SHA" "$MANIFEST_V" "$H"
      printf '    - { kind: http, name: GET /a, site: src/main.rs, schema: Record }\n'
      [ -n "${2:-}" ] && printf '%s\n' "$2"
      printf 'paths_covered:\n  - ":(top)src/**"\n---\n'
      printf '# Interfaces\n\n## Produces\n\n| Kind | Name | To | Site |\n| --- | --- | --- | --- |\n| http | GET /a | - | `src/main.rs` |\n\n'
      printf '### GET /a\n\nModel: Record\n\n## Consumes\n\nNone found.\n'
    } > "$1/09-interfaces.md"
  }
  mc_models "$S/docs/capstone"
  mc_iface_fm "$S/docs/capstone"
  git -C "$S" add docs; git -C "$S" $GC commit -qm models
  mc_run 'edges block clean' 0 'MAP CHECK: current' "$S"
  # the block's site is the one verified; the table is a rendering
  sed 's|site: src/main.rs|site: src/gone.rs|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'edges block site' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | - | site src/gone.rs | - |' 'edges block site'
  # a row with no site at all cannot point at the code it describes
  mc_iface_fm "$S/docs/capstone" '    - { kind: sqs, name: orphan, schema: Record }'
  mc_run 'edge row with no site' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | - | no site for sqs orphan | - |' 'edge row with no site'
  # a schema naming an entity 02-models.md has no section for
  mc_iface_fm "$S/docs/capstone"
  sed 's|schema: Record|schema: Nope|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'dangling schema' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | model Nope | - | - |' 'dangling schema'
  # and the same for the payload section's rendered Model: line
  mc_iface_fm "$S/docs/capstone"
  sed 's|^Model: Record$|Model: Nope|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'dangling model reference' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | model Nope | - | - |' 'dangling model reference'
  # a list schema is the same entity
  mc_iface_fm "$S/docs/capstone"
  sed 's|schema: Record|schema: Record[]|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'list schema' 0 'MAP CHECK: current' "$S"
  # a payload section holding neither a field table nor a Model: line
  mc_iface_fm "$S/docs/capstone"
  grep -v '^Model: Record$' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'empty payload section' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | payload ### GET /a | - | - |' 'empty payload section'
  # a to/from in the block is never a finding, whatever it says
  mc_iface_fm "$S/docs/capstone" '    - { kind: sqs, name: pub, site: src/main.rs, schema: Record, to: [a, b] }'
  mc_run 'to and from are never checked' 0 'MAP CHECK: current' "$S"
  # with no models chapter the reference resolves to nothing, once for
  # the two spellings of the same entity
  rm "$S/docs/capstone/02-models.md"
  mc_iface_fm "$S/docs/capstone"
  mc_run 'schema with no models chapter' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | model Record | - | - |' 'schema with no models chapter'
  # known_as (topics.md): the interfaces chapter owes the key, and a
  # scalar value is the shape quarry's known_as_of refuses, registering
  # no alias for the page and saying so only on `docs index --force`.
  # Both land in the frontmatter-keys column.
  mc_iface "$S/docs/capstone"
  sed 's|^known_as: .*|known_as: records.internal|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'scalar known_as' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | known_as not a list | - | - | - |' 'scalar known_as'
  mc_iface "$S/docs/capstone"
  grep -v '^known_as: ' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'missing known_as' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | known_as | - | - | - |' 'missing known_as'
  # a block list is a list too, and so is an empty one
  mc_iface "$S/docs/capstone"
  sed 's|^known_as: .*|known_as:\
  - records.internal|' "$S/docs/capstone/09-interfaces.md" > "$S/x" && mv "$S/x" "$S/docs/capstone/09-interfaces.md"
  mc_run 'block known_as' 0 'MAP CHECK: current' "$S"
  # the same sections written tight: no blank line before or after a
  # payload heading, which GFM allows. The heading has to close the edge
  # table, or the `| Field | Type | Required |` rows under it read as more
  # edge rows and every Type and value cell becomes a missing section.
  # The headings here also differ in case from their `Name` cell and
  # escape a pipe the way the cell does; both still match.
  mc_iface_tight() { # dir [extra Produces row]
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\nknown_as: []\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
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
  # 16c. the schema records (references/schema.txt). Every file the
  #      index reaches is now held to its record, so the folders that
  #      used to be checked for `generated_date` alone - logic/,
  #      mockup/, uiux/ - have their section lists gated too, chapters
  #      are held to heading order rather than presence, and the
  #      interfaces and models tables are held to their columns.
  mkdir -p "$S/docs/capstone/logic"
  mc_logic() { # dir: one complete scenario file
    printf -- '---\ngenerated_date: 2026-01-01\n---\n# s\n\n## Trigger & preconditions\n\nx\n\n## Steps\n\nx\n\n## Branches\n\nx\n\n## Unhappy paths\n\nx\n\n## State transitions\n\nx\n\n## Invariants\n\nx\n\n## Outcomes & side effects\n\nx\n\n## Dimensions not in play\n\nx\n' \
      > "$1/01-scenario.md"
  }
  mc_logic "$S/docs/capstone/logic"
  mc_run 'logic scenario complete' 0 'MAP CHECK: current' "$S"
  grep -v '^## Invariants$' "$S/docs/capstone/logic/01-scenario.md" > "$S/x" \
    && mv "$S/x" "$S/docs/capstone/logic/01-scenario.md"
  mc_run 'logic scenario missing a section' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/logic/01-scenario.md | - | ## Invariants | - | - |' 'logic scenario missing a section'
  rm -r "$S/docs/capstone/logic"
  # a questionnaire (core.md's Questionnaires section). It is committed
  # rather than local working state, so the gate holds it to its five
  # sections; `## How to answer` is the one dropped here, because a send
  # with no deadline and no effort estimate is the one that comes back
  # too late to use.
  mkdir -p "$S/docs/capstone/questionnaires"
  mc_questionnaire() { # dir [section heading to omit]
    { printf -- '---\ngenerated_date: 2026-01-01\n---\n# q\n\n'
      awk -v skip="${2:-}" '
        { sub(/\r$/, "") }
        /^type[ \t]+questionnaire$/ { inr = 1; next }
        /^type[ \t]/ { inr = 0 }
        inr && /^head[ \t]/ {
          sub(/^head[ \t]+/, "")
          n = split($0, H, "|")
          for (i = 1; i <= n; i++) if (H[i] != skip) printf "## %s\n\nx\n\n", H[i]
          exit
        }' skills/core/references/schema.txt
    } > "$1/2026-01-01-data-team.md"
  }
  mc_questionnaire "$S/docs/capstone/questionnaires"
  mc_run 'questionnaire complete' 0 'MAP CHECK: current' "$S"
  mc_questionnaire "$S/docs/capstone/questionnaires" 'How to answer'
  mc_run 'questionnaire missing How to answer' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/questionnaires/2026-01-01-data-team.md | - | ## How to answer | - | - |' 'questionnaire missing How to answer'
  rm -r "$S/docs/capstone/questionnaires"
  # a uiux screen chapter, the same way. `## Not in play` closes it:
  # uiux-inventory.md's gate records the items that had nothing to
  # decide, and a screen file without the section cannot tell "no
  # motion here" from "nobody asked".
  mkdir -p "$S/docs/capstone/uiux/screens"
  mc_screen() { # dir: one complete screen chapter
    printf -- '---\ngenerated_date: 2026-01-01\n---\n# s\n\n## Mode & job\n\nx\n\n## Composition\n\nx\n\n## States\n\nx\n\n## Motion\n\nx\n\n## Copy\n\nx\n\n## Not in play\n\nx\n' \
      > "$1/01-screen.md"
  }
  mc_screen "$S/docs/capstone/uiux/screens"
  mc_run 'uiux screen complete' 0 'MAP CHECK: current' "$S"
  grep -v '^## States$' "$S/docs/capstone/uiux/screens/01-screen.md" > "$S/x" \
    && mv "$S/x" "$S/docs/capstone/uiux/screens/01-screen.md"
  mc_run 'uiux screen missing a section' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/uiux/screens/01-screen.md | - | ## States | - | - |' 'uiux screen missing a section'
  mc_screen "$S/docs/capstone/uiux/screens"
  grep -v '^## Not in play$' "$S/docs/capstone/uiux/screens/01-screen.md" > "$S/x" \
    && mv "$S/x" "$S/docs/capstone/uiux/screens/01-screen.md"
  mc_run 'uiux screen with no ruled-out record' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/uiux/screens/01-screen.md | - | ## Not in play | - | - |' 'uiux screen with no ruled-out record'
  mc_screen "$S/docs/capstone/uiux/screens"
  # the system chapter's Assets manifest: the section is required and
  # its four columns are pinned, because `build` reads Status to decide
  # whether it may ship at all
  mc_system() { # dir assets-body
    printf -- '---\ngenerated_date: 2026-01-01\n---\n# y\n\n## Implementation constraints\n\nx\n\n%s\n' \
      "$2" > "$1/02-system.md"
  }
  mc_system "$S/docs/capstone/uiux" '## Assets

| Asset | File | Source | Status |
| --- | --- | --- | --- |
| logo mark | assets/logo.svg | supplied | present |'
  mc_run 'uiux system complete' 0 'MAP CHECK: current' "$S"
  mc_system "$S/docs/capstone/uiux" '## Tokens

x'
  mc_run 'uiux system with no asset manifest' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/uiux/02-system.md | - | ## Assets | - | - |' 'uiux system with no asset manifest'
  mc_system "$S/docs/capstone/uiux" '## Assets

| Asset | File | Source |
| --- | --- | --- |
| logo mark | assets/logo.svg | supplied |'
  mc_run 'assets table missing a column' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/uiux/02-system.md | - | table Assets missing Status | - | - |' 'assets table missing a column'
  # the preview is skipped entirely: no frontmatter, no record, and a
  # rendering of the chapter rather than a page of its own
  mc_system "$S/docs/capstone/uiux" '## Assets

| Asset | File | Source | Status |
| --- | --- | --- | --- |
| logo mark | assets/logo.svg | supplied | present |'
  printf -- '<!doctype html>\nAWS_ACCESS_KEY_ID=AKIA%s\n' "ABCDEFGHIJKLMNOP" \
    > "$S/docs/capstone/uiux/preview.html"
  git -C "$S" add docs/capstone/uiux/preview.html
  mc_run 'uiux preview is skipped' 0 'MAP CHECK: current' "$S"
  git -C "$S" rm -q --cached docs/capstone/uiux/preview.html
  rm -r "$S/docs/capstone/uiux"
  # standards.md's seventeen domains plus `## Not in play`. The
  # interview stops when the inventory's gate is met, so a run that
  # stopped early shows up as a heading that is not there; the sections
  # are generated from the schema record itself, which is what the gate
  # reads, so the fixture cannot drift from the contract it tests.
  mc_standards() { # dir [domain heading to omit]
    { printf -- '---\ngenerated_date: 2026-01-01\n---\n# s\n\n'
      awk -v skip="${2:-}" '
        { sub(/\r$/, "") }
        /^type[ \t]+standards$/ { inr = 1; next }
        /^type[ \t]/ { inr = 0 }
        inr && /^head[ \t]/ {
          sub(/^head[ \t]+/, "")
          n = split($0, H, "|")
          for (i = 1; i <= n; i++) if (H[i] != skip) printf "## %s\n\nx\n\n", H[i]
          exit
        }' skills/core/references/schema.txt
    } > "$1/standards.md"
  }
  mc_standards "$S/docs/capstone"
  mc_run 'standards domains complete' 0 'MAP CHECK: current' "$S"
  mc_standards "$S/docs/capstone" Security
  mc_run 'standards missing a domain' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/standards.md | - | ## Security | - | - |' 'standards missing a domain'
  rm "$S/docs/capstone/standards.md"
  # heading order: every required section is there, two of them swapped.
  # The finding names both positions, so the repair is obvious without
  # opening the file.
  mc_conv() { # dir body: a conventions chapter with the given sections
    printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\npaths_covered:\n  - ":(top)src/**"\n---\n# c\n\n%s\n' \
      "$SHA" "$MANIFEST_V" "$H" "$2" > "$1/03-conventions.md"
  }
  mc_conv "$S/docs/capstone" '## Paradigm

x

## Typing

x

## Error handling

x

## Dependency injection

x'
  mc_run 'chapter sections in order' 0 'MAP CHECK: current' "$S"
  mc_conv "$S/docs/capstone" '## Typing

x

## Paradigm

x

## Error handling

x

## Dependency injection

x'
  mc_run 'chapter sections out of order' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/03-conventions.md | - | ## Typing out of order (before ## Paradigm) | - | - |' 'chapter sections out of order'
  rm "$S/docs/capstone/03-conventions.md"
  # the models chapter's per-entity field tables, which `head` cannot
  # express: the record's `subtable` holds every `### <Entity>` under
  # Fields and types to Field, Type and Required
  mc_models "$S/docs/capstone"
  mc_run 'entity table complete' 0 'MAP CHECK: current' "$S"
  sed 's/^| Field | Type | Required |$/| Field | Type |/' "$S/docs/capstone/02-models.md" > "$S/x" \
    && mv "$S/x" "$S/docs/capstone/02-models.md"
  mc_run 'entity table missing a column' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/02-models.md | - | table Record missing Required | - | - |' 'entity table missing a column'
  rm "$S/docs/capstone/02-models.md"
  # and the interfaces chapter's own two tables, whose columns
  # topics.md spells literally
  mc_iface_cols() { # dir consumes-body
    {
      printf -- '---\ngenerated_at_commit: %s\ngenerated_date: 2026-01-01\ncapstone_version: %s\ncontent_hash: %s\nknown_as: []\npaths_covered:\n  - ":(top)src/**"\n---\n' "$SHA" "$MANIFEST_V" "$H"
      printf '# Interfaces\n\n## Produces\n\n| Kind | Name | Site |\n| --- | --- | --- |\n| http | GET /a | `src/main.rs:12` |\n\n'
      printf '### GET /a\n\n| Field | Type | Required |\n| --- | --- | --- |\n| id | string | yes |\n\n'
      printf '%s\n' "$2"
    } > "$1/09-interfaces.md"
  }
  mc_iface_cols "$S/docs/capstone" '## Consumes

| Kind | Name | From | Site |
| --- | --- | --- | --- |
| sqs | ingest | other | `src/main.rs:1` |

### ingest

| Field | Type | Required |
| --- | --- | --- |
| id | string | yes |'
  mc_run 'produces table missing a column' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | table Produces missing To | - | - |' 'produces table missing a column'
  # a required heading whose body is "None found" is what topics.md asks
  # a deep-dive to write when it found nothing, so the column test says
  # nothing about it: the Produces gap below is the only finding
  mc_iface_cols "$S/docs/capstone" '## Consumes

None found.'
  mc_run 'consumes heading with no table' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/09-interfaces.md | - | table Produces missing To | - | - |' 'consumes heading with no table'
  # back to the covered page, so the schema-file case below starts clean
  mc_iface_tight "$S/docs/capstone"
  mc_run 'covered again before the schema case' 0 'MAP CHECK: current' "$S"
  # 16d. a run whose schema.txt is not there. The script says so on its
  #      header line, holds every page to `generated_date` alone, keeps
  #      part 1, the edge pass and the secret scan, and reaches the same
  #      verdict and exit code. A gate that dies because a reference
  #      file moved is worse than one that names what it skipped. The
  #      repo's own copy is never touched: the case runs a copy of the
  #      script from a sandbox plugin root with no references/ beside it.
  mkdir -p "$T/plugin/skills/core/scripts" "$T/plugin/skills/core/references" \
           "$T/plugin/.claude-plugin"
  cp "$MCABS" "$T/plugin/skills/core/scripts/map-check.sh"
  cp .claude-plugin/plugin.json "$T/plugin/.claude-plugin/plugin.json"
  MC_BIN="$T/plugin/skills/core/scripts/map-check.sh"
  mc_run 'schema file absent' 0 'MAP CHECK: current' "$S"
  mc_row '^schema: .*schema\.txt unreadable; headings and tables not checked$' 'schema file absent'
  mc_row "| docs/capstone/08-glossary.md | $SHA | $MANIFEST_V | 0 | current |" 'schema file absent'
  mc_row '^unfolded fragments: 0 ' 'schema file absent'
  # and a page missing its date is still a finding with no schema
  printf -- '---\ncapstone_version: %s\n---\n# s\n' "$MANIFEST_V" > "$S/docs/capstone/mockup.md"
  mc_run 'schema file absent, page with no date' 1 'MAP CHECK: stale (1 findings)' "$S"
  mc_row '| docs/capstone/mockup.md | generated_date | - | - | - |' 'schema file absent, page with no date'
  rm "$S/docs/capstone/mockup.md"
  MC_BIN="$MCABS"
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

# 18. the edge contract. No repository holds the other repository's
#     name, so capstone writes what the code says - kind, name, site,
#     schema - quarry joins the two halves on (kind, name), and a
#     person answers only what that join leaves ambiguous. Three
#     things have to agree or an answer gets overwritten by a guess:
#     the rule that no run writes to/from, the section that governs
#     the ask, and the vocabulary every writer and reader uses.
grep -q '^## Edge confirmation' skills/core/references/core.md \
  || err "core.md has no Edge confirmation section"
for n in map groom architecture; do
  tr '\n' ' ' < "skills/core/references/protocols/$n.md" | tr -s ' ' \
    | grep -q 'Edge confirmation' \
    || err "protocol $n.md does not cite core.md's Edge confirmation by name"
done
for n in start feature; do
  tr '\n' ' ' < "skills/core/references/protocols/$n.md" | tr -s ' ' \
    | grep -q 'Edge confirmation' \
    || err "router $n.md does not say which stage confirms an edge"
done
for f in skills/core/references/topics.md \
         skills/core/references/protocols/map.md; do
  for s in 'edges:' 'schema' 'Model'; do
    grep -qF "$s" "$f" || err "$f does not carry the edge vocabulary: $s"
  done
done
# the ownership rule, matched against each file flattened to one line
# so re-wrapping a paragraph cannot turn the gate red
for f in skills/core/references/core.md \
         skills/core/references/protocols/map.md; do
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -q 'no run writes or edits one' \
    || err "$(basename "$f") lost the rule that no run writes to/from"
done
tr '\n' ' ' < skills/core/references/topics.md | tr -s ' ' \
  | grep -q 'It never writes `to` or `from`' \
  || err "topics.md interfaces section does not say map never writes to/from"
for f in skills/core/references/core.md \
         skills/core/references/protocols/map.md; do
  grep -q 'quarry docs index --json' "$f" \
    || err "$(basename "$f") does not read quarry's ambiguous list"
done
# the script half reads the block, and map.md documents what it finds
grep -q 'edges_of' skills/core/scripts/map-check.sh \
  || err "map-check.sh does not read the frontmatter edges block"
for s in 'no site for' 'payload ### ' 'model $pmodel'; do
  grep -qF "$s" skills/core/scripts/map-check.sh \
    || err "map-check.sh lost the edge finding: $s"
done
for s in 'no site for <kind> <name>' 'payload ### <Name>' 'model <Entity>'; do
  grep -qF "$s" skills/core/references/protocols/map.md \
    || err "map.md check part 8 does not document the edge finding: $s"
done
# models.md's entity headings are the join key a schema resolves through
tr '\n' ' ' < skills/core/references/topics.md | tr -s ' ' \
  | grep -q 'one `### <Entity>` section per entity' \
  || err "topics.md models section does not pin the ### <Entity> heading"

# 19. the project config left the ignore list in 6.3: it holds the
#     settings every run on the repo follows, so it is committed like
#     the ledger. The template must never list it again, the
#     initializer carries the migration that removes a 6.2 rule with
#     its own report line, and every file that tells a reader where
#     the config lives has to say the same thing.
grep -q '^capstone\.json$' skills/core/scripts/init-config.sh \
  && err "init-config.sh ignore template still lists capstone.json (it is committed now)"
grep -q 'unignored: capstone.json' skills/core/scripts/init-config.sh \
  || err "init-config.sh lost the capstone.json unignore migration"
for f in skills/core/scripts/init-config.sh \
         skills/core/references/core-authoring.md \
         skills/core/scripts/help.sh README.md docs/commands.md; do
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -q 'shared config, committed' \
    || err "$f does not say the project config is shared and committed"
done
tr '\n' ' ' < skills/core/references/core.md | tr -s ' ' \
  | grep -q 'Project config, shared and committed' \
  || err "core.md does not declare the project config shared and committed"
tr '\n' ' ' < skills/core/references/protocols/doctor.md | tr -s ' ' \
  | grep -q 'still listing `changelog.md` or `capstone.json`' \
  || err "doctor.md check 5 does not repair a stale capstone.json ignore rule"
# the two personal keys stay in the global file
tr '\n' ' ' < skills/core/references/core.md | tr -s ' ' \
  | grep -q 'Two keys are personal and never belong in it, `expertise` and `teaching_mode`' \
  || err "core.md does not keep expertise and teaching_mode out of the project config"
grep -q 'teaching_mode' skills/core/references/protocols/doctor.md \
  || err "doctor.md check 5 does not report a personal key in the project config"

# 20. every `head` list in the schema is the section list of the prose
#     that teaches it. Check 15 does this for the chapters by
#     regenerating topics.md's bullets; this does it for every record
#     that carries a `from`, chapters included, by reading the named
#     section of the named file. A protocol that renames a section
#     without touching the schema fails here.
#     The three shapes the prose uses for a section name are a
#     backticked `## <name>` and a bold bullet lead `- **<name>**`;
#     both are read, in document order, with several allowed on one
#     line (uiux.md Phase E puts `## Mode & job` and `## Composition`
#     side by side). The schema's list must appear in that order. A
#     section the prose names and the schema leaves out passes, because
#     a phase often lists more than one file's sections in one place -
#     mockup.md Phase E names the screen's three and the README's three
#     tables together - and telling those apart needs a marker the
#     protocols do not carry yet.
SCHEMA_TXT=skills/core/references/schema.txt
ls_sections() { # file section-name-prefix
  awk -v want="$2" '
    { sub(/\r$/, "") }
    /^## / { s = $0; sub(/^## /, "", s); inw = (index(s, want) == 1); next }
    !inw { next }
    {
      if (match($0, /^- \*\*[^*]+\*\*/)) print substr($0, 5, RLENGTH - 6)
      rest = $0
      while (match(rest, /`## [^`]+`/)) {
        print substr(rest, RSTART + 4, RLENGTH - 5)
        rest = substr(rest, RSTART + RLENGTH)
      }
    }' "$1"
}
if [ ! -f "$SCHEMA_TXT" ]; then
  err "$SCHEMA_TXT is missing (map-check.sh reads it at runtime)"
else
  LS_RECS=$(awk '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    { key = line; sub(/[ \t].*$/, "", key)
      val = line; sub(/^[^ \t]*[ \t]*/, "", val); sub(/[ \t]+$/, "", val) }
    key == "type" {
      if (t != "" && h != "" && fr != "") print t "\t" h "\t" fr
      t = val; h = ""; fr = ""; next }
    key == "head" && h == "" { h = val; next }
    key == "from" && fr == "" { fr = val; next }
    END { if (t != "" && h != "" && fr != "") print t "\t" h "\t" fr }
  ' "$SCHEMA_TXT")
  [ -n "$LS_RECS" ] || err "$SCHEMA_TXT declares no record with both head and from"
  while IFS="$LS_TAB" read -r rty rhead rfrom; do
    [ -n "$rty" ] || continue
    rfile=${rfrom%%|*}; rsect=${rfrom#*|}
    if [ "$rfile" = "$rsect" ] || [ -z "$rsect" ]; then
      err "schema record $rty has a from without a section: $rfrom"
      continue
    fi
    # a `from` naming topics.md or an inventory is a shared reference;
    # anything else is a protocol file
    case "$rfile" in
      topics.md|*-inventory.md) rpath="skills/core/references/$rfile" ;;
      *) rpath="skills/core/references/protocols/$rfile" ;;
    esac
    if [ ! -f "$rpath" ]; then
      err "schema record $rty points at $rpath, which does not exist"
      continue
    fi
    LS_GOT=$(ls_sections "$rpath" "$rsect")
    if [ -z "$LS_GOT" ]; then
      err "$rpath has no section named $rsect, or that section names no sections"
      continue
    fi
    LS_MISS=$(printf '%s\n' "$LS_GOT" | awk -v req="$rhead" '
      { g[++n] = $0 }
      END {
        m = split(req, R, "|"); j = 1
        for (i = 1; i <= m; i++) {
          hit = 0
          while (j <= n) { if (g[j++] == R[i]) { hit = 1; break } }
          if (!hit) print R[i]
        }
      }')
    [ -z "$LS_MISS" ] || err "schema record $rty disagrees with $rfile section $rsect
absent there, or out of order: $(printf '%s' "$LS_MISS" | tr '\n' ' ')
the sections that file names, in order:
$LS_GOT"
  done <<< "$LS_RECS"
fi

# 21. the schema file itself: it parses, its record ids are unique,
#     every record can be reached by a path, and map-check.sh no longer
#     carries the copy it used to embed. `--schema` is what a caller
#     asks to find out which file the gate actually read.
if [ -f "$SCHEMA_TXT" ]; then
  LS_BADFIELD=$(awk '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    line ~ /^[ \t]*$/ { next }
    { key = line; sub(/[ \t].*$/, "", key) }
    key != "type" && key != "match" && key != "keys" && key != "keys!" \
      && key != "opt" && key != "head" && key != "table" \
      && key != "subtable" && key != "from" { print FNR ": " line }
  ' "$SCHEMA_TXT")
  [ -z "$LS_BADFIELD" ] || err "$SCHEMA_TXT has lines that are not a known field:
$LS_BADFIELD"
  LS_DUPTYPE=$(sed -n 's/^type[[:space:]][[:space:]]*//p' "$SCHEMA_TXT" \
    | sed 's/[[:space:]]*$//' | sort | uniq -d)
  [ -z "$LS_DUPTYPE" ] || err "$SCHEMA_TXT repeats a type id: $(printf '%s' "$LS_DUPTYPE" | tr '\n' ' ')"
  LS_NOMATCH=$(awk '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    { key = line; sub(/[ \t].*$/, "", key)
      val = line; sub(/^[^ \t]*[ \t]*/, "", val); sub(/[ \t]+$/, "", val) }
    key == "type" { if (t != "" && m == 0) print t; t = val; m = 0; next }
    key == "match" { m++ }
    END { if (t != "" && m == 0) print t }
  ' "$SCHEMA_TXT")
  [ -z "$LS_NOMATCH" ] || err "$SCHEMA_TXT has records with no match glob: $(printf '%s' "$LS_NOMATCH" | tr '\n' ' ')"
  LS_NTYPES=$(grep -c '^type[[:space:]]' "$SCHEMA_TXT")
  LS_SCHEMA_ABS="$(cd skills/core/references && pwd -P)/schema.txt"
  LS_SCHEMA_OUT=$(bash "$MC" --schema 2>&1)
  printf '%s\n' "$LS_SCHEMA_OUT" | grep -qFx "schema: $LS_SCHEMA_ABS" \
    || err "map-check.sh --schema does not resolve to $LS_SCHEMA_ABS
got:
$LS_SCHEMA_OUT"
  printf '%s\n' "$LS_SCHEMA_OUT" | grep -qx "records: $LS_NTYPES" \
    || err "map-check.sh --schema counts a different number of records than $SCHEMA_TXT holds ($LS_NTYPES)
got:
$LS_SCHEMA_OUT"
fi
grep -q '^HEADINGS=' "$MC" \
  && err "$MC embeds a HEADINGS constant again; the schema file is the one copy"
grep -q 'references/schema\.txt' "$MC" \
  || err "$MC does not read references/schema.txt"
for f in skills/core/references/topics.md skills/core/references/protocols/map.md \
         docs/commands.md CONTRIBUTING.md; do
  grep -q 'schema\.txt' "$f" || err "$f does not name references/schema.txt"
done

# 22. the uiux completion test. logic finishes when logic-craft's
#     dimensions are each answered, cited or ruled out; uiux finishes
#     the same way or it finishes whenever the model runs out of ideas,
#     which is silent and early. So: the inventory exists, both its
#     lists carry items, the protocol reads it by name, and the two
#     artifacts it introduces - preview.html and the Assets manifest -
#     are named where they are written, ignored where they are local,
#     and consumed where build acts on them. The SVG sources are the
#     one thing under uiux/assets/ that must never be ignored.
UIUX_INV=skills/core/references/uiux-inventory.md
if [ ! -f "$UIUX_INV" ]; then
  err "$UIUX_INV is missing (uiux.md reads it as the completion test)"
else
  n=$(grep -cE '^\*\*S[0-9]+ ' "$UIUX_INV")
  [ "${n:-0}" -gt 0 ] || err "$UIUX_INV lists no system items (**S<n> ...)"
  n=$(grep -cE '^\*\*P[0-9]+ ' "$UIUX_INV")
  [ "${n:-0}" -gt 0 ] || err "$UIUX_INV lists no screen items (**P<n> ...)"
  grep -q 'uiux-inventory\.md' skills/core/references/protocols/uiux.md \
    || err "uiux.md does not read uiux-inventory.md by name"
fi
for s in 'preview.html' '## Assets' 'Not in play'; do
  grep -qF "$s" skills/core/references/protocols/uiux.md \
    || err "uiux.md does not name $s"
done
grep -qF 'Assets' skills/core/references/protocols/build.md \
  || err "build.md does not name the Assets manifest it moves and rasterizes"
grep -qF 'docs/capstone/uiux/assets/' skills/core/references/protocols/build.md \
  || err "build.md does not name the asset move out of docs/capstone/uiux/assets/"
for r in 'uiux/preview.html' 'uiux/assets/*.png' 'uiux/assets/references/'; do
  grep -qxF "$r" skills/core/scripts/init-config.sh \
    || err "init-config.sh ignore template missing rule $r"
done
grep -qxF 'uiux/assets/*.svg' skills/core/scripts/init-config.sh \
  && err "init-config.sh ignores uiux/assets/*.svg (the mark itself is committed)"
tr '\n' ' ' < skills/core/references/core-authoring.md | tr -s ' ' \
  | grep -qF '`uiux/assets/*.svg` is **NOT** on this list' \
  || err "core-authoring.md does not keep uiux/assets/*.svg off the local-only list"

# 23. the standards inventory and stack's derivation. standards.md
#     walked nine domains of inline prose and stopped when the model ran
#     out of questions; the domains now live in one inventory with a
#     gate, and three copies have to agree - the inventory's §3 list,
#     the `### ` blocks holding its items, and the schema record the
#     gate enforces. Check 20 ties the schema's `head` to §3; this ties
#     §3 to §4 and pins the eight domains the nine-domain version was
#     missing. The stack half asserts that the capability list is
#     derived from the documents rather than recalled, and that every
#     capability reaches the user as options.
SI=skills/core/references/standards-inventory.md
if [ ! -f "$SI" ]; then
  err "$SI is missing (protocols/standards.md reads it before its first question)"
else
  grep -q 'standards-inventory\.md' skills/core/references/protocols/standards.md \
    || err "standards.md does not read standards-inventory.md by name"
  SI_DOMAINS=$(sed -n 's/^### //p' "$SI")
  SI_N=$(printf '%s\n' "$SI_DOMAINS" | grep -c '.')
  [ "$SI_N" -ge 17 ] \
    || err "$SI carries $SI_N domains; the sweep needs at least 17"
  for d in Security Accessibility 'API conventions' 'Logging and privacy' \
           'Performance budgets' Documentation 'Versioning and release' \
           'CI gates'; do
    printf '%s\n' "$SI_DOMAINS" | grep -qx "$d" \
      || err "$SI has no '### $d' domain"
  done
  SI_LIST=$(sed -n '/^## 3\. The domains/,/^## 4\./p' "$SI" \
    | sed -n 's/^- \*\*\([^*]*\)\*\*.*/\1/p' | grep -v '^Not in play$')
  [ "$SI_LIST" = "$SI_DOMAINS" ] || err "$SI section 3's list differs from its ### blocks
section 3:
$SI_LIST
section 4:
$SI_DOMAINS"
  SI_HEAD=$(awk '
    { sub(/\r$/, "") }
    /^type[ \t]+standards$/ { inr = 1; next }
    /^type[ \t]/ { inr = 0 }
    inr && /^head[ \t]/ { sub(/^head[ \t]+/, ""); print; exit }
  ' skills/core/references/schema.txt)
  if [ -z "$SI_HEAD" ]; then
    err "schema.txt's standards record carries no head (the gate cannot check the domains)"
  else
    SI_WANT=$(printf '%s\n' "$SI_DOMAINS" | tr '\n' '|')'Not in play'
    [ "$SI_HEAD" = "$SI_WANT" ] || err "schema.txt's standards head differs from $SI
schema:    $SI_HEAD
inventory: $SI_WANT"
  fi
fi
ST=skills/core/references/protocols/stack.md
grep -q 'typically' "$ST" \
  && err "$ST recalls capabilities from a 'typically' list instead of deriving them"
ST_FLAT=$(tr '\n' ' ' < "$ST" | tr -s ' ')
for s in 'External services' 'Communication' 'Side-effect boundaries' \
         '07-operations.md' 'uiux/02-system.md'; do
  printf '%s\n' "$ST_FLAT" | grep -qF "$s" \
    || err "$ST does not derive the capability list from $s"
done
printf '%s\n' "$ST_FLAT" | grep -qF 'write it ourselves' \
  || err "$ST does not offer the write-it-ourselves option in every list"
printf '%s\n' "$ST_FLAT" | grep -qF 'presents first and recommends' \
  || err "$ST's ladder still gates the capability instead of ranking the options"

# 24. the readback's coverage half, and the payload questions upstream
#     of it. Every stage now finishes against an inventory, so the one
#     thing the readback could not see was an item nobody asked about:
#     the pass runs three halves, and the first is only runnable if
#     start.md names each inventory it walks. Upstream of that,
#     02-models.md pins a `### <Entity>` field table per entity and
#     09-interfaces.md's `schema` resolves through it, so the
#     architecture interview has to ask for the fields rather than let
#     the chapter infer them - a guess there is what the first
#     `quarry check` compares against.
SBK=skills/core/references/protocols/start.md
SBK_FLAT=$(tr '\n' ' ' < "$SBK" | tr -s ' ')
printf '%s\n' "$SBK_FLAT" | grep -qF 'three halves' \
  || err "$SBK step 7 still runs two halves of the readback"
SBK_COV=$(awk '
  /\*\*Coverage: what nobody asked\.\*\*/ { inp = 1 }
  inp && /\*\*Misplacement: move it to its owner\.\*\*/ { exit }
  inp { print }
' "$SBK" | tr '\n' ' ' | tr -s ' ')
if [ -z "$SBK_COV" ]; then
  err "$SBK step 7 lost the coverage half (Coverage: what nobody asked)"
else
  for s in '`logic-craft.md` §3' '`uiux-inventory.md` §3' \
           '`interview.md` §0-§4' '`standards-inventory.md` §3' \
           '`stack.md` Phase A'; do
    printf '%s\n' "$SBK_COV" | grep -qF "$s" \
      || err "$SBK's coverage half does not walk $s"
  done
  printf '%s\n' "$SBK_COV" | grep -qF 'one digest rather than a debate' \
    || err "$SBK's coverage half is a debate rather than one digest"
  printf '%s\n' "$SBK_COV" | grep -qF 'empty' \
    || err "$SBK's coverage half never says an empty digest is still reported"
fi
grep -qF 'names what nobody asked' docs/commands.md \
  || err "docs/commands.md does not carry the readback's coverage half"
IVF=skills/core/references/interview.md
IV_COMM=$(sed -n '/^- Communication: protocols per edge/,/^- Composition:/p' "$IVF" \
  | tr '\n' ' ' | tr -s ' ')
if [ -z "$IV_COMM" ]; then
  err "$IVF has no Communication bullet under → architecture.md"
else
  for s in 'payload' '02-models.md' '### <Entity>' 'schema'; do
    printf '%s\n' "$IV_COMM" | grep -qF "$s" \
      || err "$IVF's Communication bullet asks for no payload, or names no $s"
  done
fi
IV_MOD=$(sed -n '/^- Core entities and their relationships/,/^- Storage paradigm/p' "$IVF" \
  | tr '\n' ' ' | tr -s ' ')
if [ -z "$IV_MOD" ]; then
  err "$IVF has no core-entities bullet under → models.md"
else
  for s in 'fields' 'type' 'optional' 'accepted values'; do
    printf '%s\n' "$IV_MOD" | grep -qF "$s" \
      || err "$IVF's core-entities bullet settles no per-field $s"
  done
fi
ARC=skills/core/references/protocols/architecture.md
ARC_CRIT=$(awk '
  /^\*\*The exhaustiveness criterion/ { inp = 1 }
  inp && /^$/ { exit }
  inp { print }
' "$ARC" | tr '\n' ' ' | tr -s ' ')
if [ -z "$ARC_CRIT" ]; then
  err "$ARC lost the exhaustiveness criterion paragraph"
else
  for s in 'schema' '09-interfaces.md' '### <Entity>'; do
    printf '%s\n' "$ARC_CRIT" | grep -qF "$s" \
      || err "$ARC's exhaustiveness criterion does not reach payloads via $s"
  done
fi

# 25. two moves that only work if several files agree. First: the
#     questionnaire. core.md owns the section list, schema.txt's
#     `questionnaire` record is what the gate enforces, and the six
#     interview protocols are the only places the offer is ever made,
#     so a section renamed in one of the three is a send the gate
#     rejects or a rule nobody reaches. Check 20 cannot tie these two
#     together, because it resolves a `from` file to topics.md, an
#     inventory or a protocol, and this list lives in core.md.
#     Second: standards enforcement moved to the reviewer. implement.md
#     must not load standards.md into the implementation path, plan.md
#     must copy every rule that binds the feature, and build.md's
#     code-writing phase must work off implementation.md's copy - or
#     the rules silently stop binding anything.
CQ=skills/core/references/core.md
CQ_SECT=$(awk '
  { sub(/\r$/, "") }
  /^## Questionnaires/ { inp = 1; next }
  inp && /^## / { exit }
  inp { print }' "$CQ")
if [ -z "$CQ_SECT" ]; then
  err "$CQ has no ## Questionnaires section"
else
  printf '%s\n' "$CQ_SECT" | tr '\n' ' ' | tr -s ' ' \
    | grep -qF 'Never invent a question to fill the document out' \
    || err "$CQ's Questionnaires section does not forbid padding the document"
  CQ_HEADS=$(printf '%s\n' "$CQ_SECT" | awk '
    { rest = $0
      while (match(rest, /`## [^`]+`/)) {
        print substr(rest, RSTART + 4, RLENGTH - 5)
        rest = substr(rest, RSTART + RLENGTH)
      } }' | tr '\n' '|' | sed 's/|$//')
  CQ_SCHEMA=$(awk '
    { sub(/\r$/, "") }
    /^type[ \t]+questionnaire$/ { inr = 1; next }
    /^type[ \t]/ { inr = 0 }
    inr && /^head[ \t]/ { sub(/^head[ \t]+/, ""); print; exit }
  ' "$SCHEMA_TXT")
  if [ -z "$CQ_SCHEMA" ]; then
    err "$SCHEMA_TXT has no questionnaire record carrying a head list"
  else
    [ "$CQ_HEADS" = "$CQ_SCHEMA" ] \
      || err "$SCHEMA_TXT's questionnaire head disagrees with $CQ's section list
core.md:    $CQ_HEADS
schema.txt: $CQ_SCHEMA"
  fi
  awk '
    { sub(/\r$/, "") }
    /^type[ \t]+questionnaire$/ { inr = 1; next }
    /^type[ \t]/ { inr = 0 }
    inr { print }' "$SCHEMA_TXT" | grep -q '^match[ \t]*questionnaires/\*\.md$' \
    || err "$SCHEMA_TXT's questionnaire record does not match questionnaires/*.md"
fi
grep -q 'questionnaires/' skills/core/references/core-authoring.md \
  || err "core-authoring.md does not place questionnaires/ (committed, and a Companion docs row)"
for p in architecture logic mockup stack standards uiux; do
  tr '\n' ' ' < "skills/core/references/protocols/$p.md" | tr -s ' ' \
    | grep -qF "core.md's Questionnaires" \
    || err "protocol $p.md never offers a questionnaire (core.md's Questionnaires)"
done
IMP=skills/core/references/protocols/implement.md
IMP_READS=$(awk '/^\*\*Reads:\*\*/ { inp = 1 } inp { print; if (/^$/) exit }' "$IMP" \
  | tr '\n' ' ' | tr -s ' ')
if [ -z "$IMP_READS" ]; then
  err "$IMP has no **Reads:** block to check"
else
  printf '%s\n' "$IMP_READS" | grep -qF '`standards.md` (Phase C' \
    || err "$IMP's Reads block does not park standards.md in Phase C"
  IMP_N=$(printf '%s\n' "$IMP_READS" | grep -o 'standards\.md' | grep -c '.')
  [ "$IMP_N" -eq 1 ] \
    || err "$IMP's Reads block names standards.md $IMP_N times; once, in Phase C"
fi
IMP_AB=$(awk '/^## Phase A/ { inp = 1 } /^## Phase C/ { exit } inp { print }' "$IMP" \
  | grep -v 'never `standards.md`')
[ -n "$IMP_AB" ] || err "$IMP has no Phase A or Phase B to check"
printf '%s\n' "$IMP_AB" | grep -qF 'standards.md' \
  && err "$IMP still loads standards.md into the implementation path (Phase A or B)"
printf '%s\n' "$IMP_AB" | grep -qF "plan's Header" \
  || err "$IMP's implementation path cites no constraints from the plan's Header"
IMP_C=$(awk '/^## Phase C/ { inp = 1; next } inp && /^## Phase D/ { exit } inp { print }' "$IMP" \
  | tr '\n' ' ' | tr -s ' ')
if [ -z "$IMP_C" ]; then
  err "$IMP has no Phase C to check"
else
  printf '%s\n' "$IMP_C" | grep -qF 'standards.md' \
    || err "$IMP's Phase C lost the standards.md review lens"
  printf '%s\n' "$IMP_C" | grep -qF 'enforcement lives here' \
    || err "$IMP's Phase C does not say why enforcement lives with the reviewer"
fi
PLN=skills/core/references/protocols/plan.md
tr '\n' ' ' < "$PLN" | tr -s ' ' \
  | grep -qF 'only binding if the plan copies it' \
  || err "$PLN's Header bullet does not require every binding rule to be copied"
BLD=skills/core/references/protocols/build.md
BLD_C=$(awk '/^## Phase C/ { inp = 1; next } inp && /^## After/ { exit } inp { print }' "$BLD" \
  | grep -v 'never `standards.md`')
[ -n "$BLD_C" ] || err "$BLD has no Phase C to check"
printf '%s\n' "$BLD_C" | grep -qF 'standards.md' \
  && err "$BLD still loads standards.md into its code-writing phase"
printf '%s\n' "$BLD_C" | grep -qF 'Global constraints' \
  || err "$BLD's Phase C cites no Global constraints from implementation.md"
tr '\n' ' ' < "$BLD" | tr -s ' ' | grep -qF '**Global constraints**' \
  || err "$BLD's Phase A does not make implementation.md carry a Global constraints section"

# 26. every command owes a page in docs/commands/, each page carries the
#     four fixed headings in order, no page teaches installation, and
#     docs/commands.md points at the folder. docs/commands.md answers
#     "what are this command's arguments"; it does not answer "which
#     command do I reach for now" or "how do I know it worked", and
#     those are the questions a user-invoked command generates, because
#     nothing fires it on the user's behalf. A missing page is a command
#     nobody can choose; a page whose headings drifted is a page a
#     reader cannot skim next to its siblings; an install command there
#     is a second copy of README.md's install block, which is exactly
#     the kind of duplicate that goes stale unread.
DOCPAGE_HEADS="## What it does|## When to reach for it|## Common questions|## It's working if"
for d in skills/*/; do
  n=$(basename "$d")
  case "$n" in core) continue;; esac
  dp="docs/commands/$n.md"
  if [ ! -f "$dp" ]; then
    err "$dp is missing (every command except core owes a page)"
    continue
  fi
  DP_HAVE=0
  for h in '## What it does' '## When to reach for it' \
           '## Common questions' "## It's working if"; do
    if grep -qx "$h" "$dp"; then
      DP_HAVE=$((DP_HAVE + 1))
    else
      err "$dp has no '$h' heading"
    fi
  done
  if [ "$DP_HAVE" -eq 4 ]; then
    DP_SEQ=$(grep '^## ' "$dp" | awk -v req="$DOCPAGE_HEADS" '
      { g[++c] = $0 }
      END {
        m = split(req, R, "|"); j = 1
        for (i = 1; i <= m; i++) {
          hit = 0
          while (j <= c) { if (g[j++] == R[i]) { hit = 1; break } }
          if (!hit) { print R[i]; break }
        }
      }')
    [ -z "$DP_SEQ" ] \
      || err "$dp carries the fixed headings out of order: $DP_SEQ is out of sequence"
  fi
  DP_INST=$(grep -En 'npx skills add|gh skill install|plugin install|plugin marketplace add|extensions install|agy plugin' "$dp" | head -1)
  [ -n "$DP_INST" ] \
    && err "$dp carries an install command ($DP_INST); installing lives in README.md alone"
done
for dp in docs/commands/*.md; do
  [ -e "$dp" ] || continue
  n=$(basename "$dp" .md)
  [ -d "skills/$n" ] || err "$dp documents $n, which is not a skill (a page for a retired command)"
done
grep -q 'docs/commands/' docs/commands.md \
  || err "docs/commands.md does not name the docs/commands/ folder its pages live in"

# 27. retro's wiring, named rather than derived. Checks 5, 5b and 5c
#     iterate over whatever skills/ happens to hold, so deleting
#     skills/retro/ makes all three pass again with the command gone
#     from every surface. This names it, the way check 10b names the
#     commands that must stay gone. The protocol's own load-bearing
#     parts are asserted here too: seven candidates, because a retro
#     that walks five reports a clean environment it never looked at,
#     and the placement rule, which is the one sentence that decides
#     where an approved rule lands.
[ -f skills/retro/SKILL.md ] || err "skills/retro/SKILL.md is missing"
RETRO_MD=skills/core/references/protocols/retro.md
[ -f "$RETRO_MD" ] || err "$RETRO_MD is missing"
bash skills/core/scripts/help.sh | grep -Eq '^  retro( |$)' \
  || err "help.sh has no retro command line"
grep -q '/capstone:retro[` ]' README.md \
  || err "README command table missing /capstone:retro"
sed -n '/matches a capstone skill/,/invoke capstone:/p' README.md \
  | grep -Eq '(^|[ (])retro[,)]' \
  || err "README routing snippet missing retro"
grep -Eq '(^|[ (])retro[,)]' .opencode/INSTALL.md \
  || err "INSTALL.md skill list missing retro"
sed -n '/The reserved subcommand words/,/each route to/p' \
  skills/core/references/dispatcher.md | grep -q '`retro`' \
  || err "dispatcher.md routing list missing retro"
grep -q '^### `retro`' docs/commands.md \
  || err "docs/commands.md has no retro section"
if [ -f "$RETRO_MD" ]; then
  for s in 'Navigation' 'Automated checks' 'Standards rules' \
           'Steering-file bloat' 'Tool economy' 'No-ops' \
           'Information access'; do
    grep -qF "**$s.**" "$RETRO_MD" \
      || err "$RETRO_MD lost the candidate category: $s"
  done
  grep -qF 'the reviewer wherever a reviewer can check it' "$RETRO_MD" \
    || err "$RETRO_MD lost the implementation-versus-review placement rule"
  grep -qF 'retro/<scope>@<stamp>' "$RETRO_MD" \
    || err "$RETRO_MD does not name its ledger key"
fi

[ "$FAIL" -eq 0 ] && echo "lint-sync: all invariants hold" || echo "lint-sync: FAILURES above"
exit $FAIL
