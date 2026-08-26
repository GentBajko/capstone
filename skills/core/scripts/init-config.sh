#!/usr/bin/env bash
# Materializes capstone's files, idempotently:
#   0. creates the global config <global>/capstone.json if absent
#      (--global: do only this, the SessionStart hook's mode, silent
#       unless it creates)
#   1. migrates a legacy docs/design tree to docs/capstone
#   2. creates <docs_dir>/.gitignore if absent; drops the stale
#      changelog.md rule from an existing one
# The global folder is ~/.claude, or $CLAUDE_CONFIG_DIR when the agent
# sets it ($CAPSTONE_GLOBAL_DIR overrides both, for non-Claude agents).
# The per-project docs/capstone/capstone.json is never created here:
# it is optional override/state, written by protocols only when a
# project-scoped key gets recorded (see core.md). The .gitignore goes
# in the docs area, which the docs_dir argument may relocate.
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
  "expertise": null,
  "teaching_mode": false,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en"
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

# 2. the docs area's ignore list
mkdir -p "$DOCS_DIR"
IGNORE="$DOCS_DIR/.gitignore"
if [ -f "$IGNORE" ]; then
  # Older versions ignored changelog.md. It is part of the reference
  # now (follows docs_in_git), so drop the stale rule. sed, not
  # grep -v: grep exits 1 when nothing survives, which set -e would
  # turn into a crash on a one-line ignore file.
  if grep -q '^changelog\.md$' "$IGNORE"; then
    sed '/^changelog\.md$/d' "$IGNORE" > "$IGNORE.capstone-tmp" \
      && mv "$IGNORE.capstone-tmp" "$IGNORE"
    echo "unignored: changelog.md in $IGNORE"
  else
    echo "exists: $IGNORE"
  fi
else
  cat > "$IGNORE" <<'EOF'
# Capstone's local-only outputs. Committed docs are the factual
# reference; everything listed here is personal working state.
# The feature chain (groom -> plan -> implement) never commits.

# Feature working files: interviews, specs, plans, review ledgers
features/

# Interview transcripts for every other stage
*-interview.md

# Local settings
capstone.json

# Opinionated and personal outputs
review.md
be-review.md
fe-review.md
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
