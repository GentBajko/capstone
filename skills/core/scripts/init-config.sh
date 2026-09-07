#!/usr/bin/env bash
# Materializes capstone's files, idempotently:
#   0. creates the global config <global>/capstone.json if absent
#      (--global: do only this, the SessionStart hook's mode, silent
#       unless it creates)
#   1. migrates a legacy docs/design tree to docs/capstone
#   2. creates <docs_dir>/.gitignore if absent; drops the stale
#      changelog.md and capstone.json rules from an existing one, one
#      report line each (both may fire in one run)
# The global folder is ~/.claude, or $CLAUDE_CONFIG_DIR when the agent
# sets it ($CAPSTONE_GLOBAL_DIR overrides both, for non-Claude agents).
# The per-project docs/capstone/capstone.json is never created here:
# it is the project's shared config, committed whatever docs_in_git
# says, and written by protocols only when a project-scoped key gets
# recorded (see core.md). The .gitignore goes in the docs area, which
# the docs_dir argument may relocate.
# Never overwrites an existing config; only the stale-rule removal
# above touches an existing ignore file.
# Usage: init-config.sh [--global] [docs_dir]
set -eu
GLOBAL_ONLY=0
if [ "${1:-}" = "--global" ]; then GLOBAL_ONLY=1; shift; fi
DOCS_DIR="${1:-docs/capstone}"
LEGACY="docs/design"
TARGET="docs/capstone"

# 0. the global config
GLOBAL_DIR="${CAPSTONE_GLOBAL_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"
GLOBAL_FILE="$GLOBAL_DIR/capstone.json"
if [ ! -f "$GLOBAL_FILE" ]; then
  mkdir -p "$GLOBAL_DIR"
  cat > "$GLOBAL_FILE" <<'EOF'
{
  // Comments are allowed in this file; capstone reads around them.
  "expertise": null,                  // null = ask once | 1 vibe | 2 explorer | 3 builder | 4 engineer | 5 architect; conversation only, never the docs
  "teaching_mode": false,             // true = narrate each step and the concept behind it, at any expertise level
  "docs_dir": "docs/capstone",        // where generated docs land; relative path inside the repo
  "index_file": "docs/capstone/00-index.md", // chapter zero of the docs area; relative path inside the repo
  "subagent_threshold": 150,          // source-file count where map fans out to subagents and unrequested full builds ask first
  "docs_in_git": "ask",               // "commit" | "ignore" | "ask" - the factual reference only; the ledger is always committed
  "language": "en",                   // language the generated docs are written in
  "non_interactive": false,           // true = resolve every defaulted prompt silently (CI); approval gates still stop
  "extract": ["logic", "uiux"],       // map's extraction passes: ["logic","uiux"] both | ["logic"] skip uiux | [] skip both
  "interfaces": "auto",               // "auto" = write 09-interfaces.md when the repo talks to another repo | "off" = never
  "interfaces_frontmatter": false,    // true = also mirror the interface tables into frontmatter, for machine consumers
  "cross_repo": "auto",               // "auto" = groom/plan/architecture/map consult quarry when installed (groom/plan also need 09-interfaces.md) | "off" = never
  "redact": ["*_SECRET", "*_TOKEN", "*_PASSWORD", "*_KEY"] // env-var name patterns whose values the docs never quote; * matches any prefix or suffix
}
EOF
  echo "created: $GLOBAL_FILE"
fi
if [ "$GLOBAL_ONLY" -eq 1 ]; then exit 0; fi

# Portable in-place edit (BSD sed needs an -i argument; GNU sed does not).
rewrite() {
  sed 's|docs/design|docs/capstone|g' "$1" > "$1.capstone-tmp" \
    && mv "$1.capstone-tmp" "$1"
}

# 1. Retroactive migration. Only when the new tree does not exist yet;
#    if both are present this is not a stale layout and nothing is merged.
if [ -d "$LEGACY" ] && [ ! -d "$TARGET" ]; then
  mkdir -p "$(dirname "$TARGET")"
  if [ -n "$(git ls-files "$LEGACY" 2>/dev/null | head -1)" ]; then
    git mv "$LEGACY" "$TARGET" 2>/dev/null || mv "$LEGACY" "$TARGET"
  else
    mv "$LEGACY" "$TARGET"
  fi
  echo "migrated: $LEGACY -> $TARGET"

  # Repoint the paths the move invalidated: the generated docs' own
  # cross-references, the root index, and docs_dir if it named the old
  # default (a custom docs_dir is left alone).
  find "$TARGET" -type f -name '*.md' -exec sh -c '
    for f do
      sed "s|docs/design|docs/capstone|g" "$f" > "$f.capstone-tmp" \
        && mv "$f.capstone-tmp" "$f"
    done' sh {} +
  IDX="DESIGN.md"
  if [ -f "$TARGET/capstone.json" ]; then
    v=$(sed -n 's/.*"index_file"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
      "$TARGET/capstone.json" | head -1)
    [ -n "$v" ] && IDX="$v"
    rewrite "$TARGET/capstone.json"
  fi
  [ -f "$IDX" ] && rewrite "$IDX"
  echo "repointed: $TARGET/**/*.md, $IDX, docs_dir"
  if [ "$DOCS_DIR" = "$LEGACY" ]; then DOCS_DIR="$TARGET"; fi
elif [ -d "$LEGACY" ] && [ -d "$TARGET" ]; then
  echo "note: both $LEGACY and $TARGET exist - not merging; $TARGET wins"
fi

# 1b. The index moved out of the repository root into the docs area as
#     chapter zero. Only fires for the old default (a custom index_file
#     is left alone) and only when the new location is still free; both
#     present is not a stale layout, so nothing is merged.
OLD_IDX="DESIGN.md"
NEW_IDX="$DOCS_DIR/00-index.md"
CFG_IDX=""
if [ -f "$DOCS_DIR/capstone.json" ]; then
  CFG_IDX=$(sed -n 's/.*"index_file"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    "$DOCS_DIR/capstone.json" | head -1)
fi
if [ -f "$OLD_IDX" ] && [ ! -f "$NEW_IDX" ] \
   && { [ -z "$CFG_IDX" ] || [ "$CFG_IDX" = "$OLD_IDX" ]; }; then
  mkdir -p "$DOCS_DIR"
  if [ -n "$(git ls-files "$OLD_IDX" 2>/dev/null | head -1)" ]; then
    git mv "$OLD_IDX" "$NEW_IDX" 2>/dev/null || mv "$OLD_IDX" "$NEW_IDX"
  else
    mv "$OLD_IDX" "$NEW_IDX"
  fi
  echo "migrated: $OLD_IDX -> $NEW_IDX"

  # The index's own rows were relative to the repo root; the chapters
  # now sit beside it. Repoint both link targets and link text, then
  # every docs-area reference to the old root path. POSIX regex only
  # (no \b): "DESIGN.md" is specific enough to replace unanchored.
  sed -e "s|($DOCS_DIR/|(|g" -e "s|\[$DOCS_DIR/|[|g" -e "s|\](\./|](|g" \
    "$NEW_IDX" > "$NEW_IDX.capstone-tmp" && mv "$NEW_IDX.capstone-tmp" "$NEW_IDX"
  find "$DOCS_DIR" -type f -name '*.md' -exec sh -c '
    for f do
      sed -e "s|/DESIGN\.md|/00-index.md|g" -e "s|DESIGN\.md|00-index.md|g" \
        "$f" > "$f.capstone-tmp" && mv "$f.capstone-tmp" "$f"
    done' sh {} +
  if [ -n "$CFG_IDX" ]; then
    sed "s|\"$OLD_IDX\"|\"$NEW_IDX\"|" "$DOCS_DIR/capstone.json" \
      > "$DOCS_DIR/capstone.json.capstone-tmp" \
      && mv "$DOCS_DIR/capstone.json.capstone-tmp" "$DOCS_DIR/capstone.json"
  fi
  echo "repointed: $NEW_IDX and $DOCS_DIR/**/*.md"
  echo "note: drop the Commit/Generated columns from $NEW_IDX; freshness lives in each file's frontmatter"
elif [ -f "$OLD_IDX" ] && [ -f "$NEW_IDX" ]; then
  echo "note: both $OLD_IDX and $NEW_IDX exist - not merging; $NEW_IDX wins"
fi

# 1c. Stage renames: design -> uiux (design/ and design-interview.md),
#     and code-prefs -> standards (code-prefs.md and its interview).
#     Move each when the new name is still free; both present is not a
#     stale layout, so nothing merges.
for pair in "design:uiux" "design-interview.md:uiux-interview.md" \
            "code-prefs.md:standards.md" \
            "code-prefs-interview.md:standards-interview.md"; do
  old="$DOCS_DIR/${pair%%:*}"; new="$DOCS_DIR/${pair##*:}"
  if [ -e "$old" ] && [ ! -e "$new" ]; then
    if [ -n "$(git ls-files "$old" 2>/dev/null | head -1)" ]; then
      git mv "$old" "$new" 2>/dev/null || mv "$old" "$new"
    else
      mv "$old" "$new"
    fi
    echo "migrated: $old -> $new"
  elif [ -e "$old" ] && [ -e "$new" ]; then
    echo "note: both $old and $new exist - not merging; $new wins"
  fi
done
if [ -d "$DOCS_DIR/uiux" ] || [ -f "$DOCS_DIR/uiux-interview.md" ] \
   || [ -f "$DOCS_DIR/standards.md" ] || [ -f "$DOCS_DIR/standards-interview.md" ]; then
  # Repoint the cross-references the moves invalidated. The interview
  # substitution runs first: code-prefs-interview.md does not contain
  # the string code-prefs.md, but keeping the specific rule ahead of the
  # general one is how this stays true if either name ever changes.
  find "$DOCS_DIR" -type f -name '*.md' -exec sh -c '
    for f do
      sed -e "s|docs/capstone/design/|docs/capstone/uiux/|g" \
          -e "s|design-interview\.md|uiux-interview.md|g" \
          -e "s|code-prefs-interview\.md|standards-interview.md|g" \
          -e "s|code-prefs\.md|standards.md|g" \
          "$f" > "$f.capstone-tmp" && mv "$f.capstone-tmp" "$f"
    done' sh {} +
fi

# 2. the docs area's ignore list
mkdir -p "$DOCS_DIR"
IGNORE="$DOCS_DIR/.gitignore"
if [ -f "$IGNORE" ]; then
  migrated=0
  # Older versions ignored changelog.md. It is part of the reference
  # now (follows docs_in_git), so drop the stale rule. sed, not
  # grep -v: grep exits 1 when nothing survives, which set -e would
  # turn into a crash on a one-line ignore file.
  if grep -q '^changelog\.md$' "$IGNORE"; then
    sed '/^changelog\.md$/d' "$IGNORE" > "$IGNORE.capstone-tmp" \
      && mv "$IGNORE.capstone-tmp" "$IGNORE"
    echo "unignored: changelog.md in $IGNORE"
    migrated=1
  fi
  # 6.2 and earlier ignored capstone.json. The project config is the
  # team's shared settings now and is always committed (core.md), so
  # the rule goes the same way. The awk also drops the template's own
  # "# Local settings" comment when it sits directly above the rule,
  # and the blank line the pair leaves behind, so a migrated file
  # reads like a fresh one; a comment with anything else under it is
  # kept. Both migrations may fire in one run, one line each.
  if grep -q '^capstone\.json$' "$IGNORE"; then
    awk '
      held == 1 && $0 == "capstone.json" { held = 0; eat = 1; next }
      held == 1 { print "# Local settings"; held = 0 }
      $0 == "# Local settings" { held = 1; next }
      $0 == "capstone.json" { next }
      eat == 1 { eat = 0; if ($0 == "" && blank == 1) next }
      { print; blank = ($0 == "") }
      END { if (held == 1) print "# Local settings" }' "$IGNORE" \
      > "$IGNORE.capstone-tmp" && mv "$IGNORE.capstone-tmp" "$IGNORE"
    echo "unignored: capstone.json in $IGNORE"
    migrated=1
  fi
  # 6.4 added the uiux stage's preview and its raster brand assets.
  # Appended rather than rewritten, so a hand-edited ignore file keeps
  # its own rules; each rule is added only when it is absent, so a
  # second run adds nothing. uiux/assets/*.svg is never added: the mark
  # is committed, for the reason the template's header gives.
  added=""
  for rule in uiux/preview.html 'uiux/assets/*.png' 'uiux/assets/*.jpg' \
              'uiux/assets/*.jpeg' 'uiux/assets/*.webp' uiux/assets/references/; do
    if ! grep -qxF "$rule" "$IGNORE"; then
      added="$added$rule
"
    fi
  done
  if [ -n "$added" ]; then
    { cat "$IGNORE"
      echo
      echo "# The uiux preview and raster brand assets; the SVG sources are committed"
      printf '%s' "$added"; } > "$IGNORE.capstone-tmp" \
      && mv "$IGNORE.capstone-tmp" "$IGNORE"
    echo "ignored: the uiux preview and raster assets in $IGNORE"
    migrated=1
  fi
  [ "$migrated" -eq 1 ] || echo "exists: $IGNORE"
else
  cat > "$IGNORE" <<'EOF'
# Capstone's local-only outputs. Committed docs are the factual
# reference; everything listed here is personal working state.
# The feature chain (groom -> plan -> implement) never commits.
# changelog.md and changelog.d/ are deliberately NOT here and must
# never be added: the ledger is always committed, whatever
# docs_in_git says, because implement deletes each feature folder on
# the strength of its entry. capstone.json is not here either: it is
# the project's shared config, committed for the same reason a
# standard is written down rather than kept on one machine.
# uiux/assets/*.svg is deliberately NOT here either and must never be
# added: the SVG is the mark itself, the file build moves into the
# app and rasterises the favicon from, and a logo that lives on one
# machine is not a brand.

# Feature working files: interviews, specs, plans, review ledgers
features/

# Interview transcripts for every other stage
*-interview.md

# Opinionated and personal outputs
review.md

# Superseded by review.md; listed so older repos stay ignored
be-review.md
fe-review.md

# The uiux stage's rendered preview: a picture of 02-system.md, not a
# deliverable, and hard rule 4 says the outputs are markdown
uiux/preview.html

# Raster brand assets and reference material. The SVG sources beside
# them are committed (see above); these are exports and mood boards.
uiux/assets/*.png
uiux/assets/*.jpg
uiux/assets/*.jpeg
uiux/assets/*.webp
uiux/assets/references/
EOF
  echo "created: $IGNORE"
fi

# 3. Retroactive untracking. A repo that committed these before the
#    ignore list existed keeps tracking them - .gitignore only affects
#    untracked paths. Drop them from the index; every file stays on disk.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for d in "$DOCS_DIR" "$TARGET"; do
    [ -d "$d" ] || continue
    n=$(git ls-files -i -c --exclude-standard -- "$d" 2>/dev/null | grep -c . || true)
    if [ "${n:-0}" -gt 0 ]; then
      # -f: a migrated file can have staged content differing from both
      # the worktree and HEAD, which plain rm --cached refuses. --cached
      # keeps the working file either way.
      git ls-files -z -i -c --exclude-standard -- "$d" \
        | xargs -0 git rm --cached --force --quiet --
      echo "untracked $n file(s) under $d now covered by .gitignore (kept on disk)"
    fi
  done
fi
