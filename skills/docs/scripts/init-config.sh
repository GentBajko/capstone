#!/usr/bin/env bash
# Materializes capstone's local files, idempotently:
#   0. migrates a legacy docs/design tree to docs/capstone
#   1. creates docs/capstone/capstone.json if absent
#   2. creates <docs_dir>/.gitignore if absent
# The config path is fixed regardless of docs_dir (see core.md); the
# .gitignore goes in the docs area, which $1 may relocate.
# Never overwrites an existing config or ignore file.
# Usage: init-config.sh [docs_dir]
set -eu
DOCS_DIR="${1:-docs/capstone}"
LEGACY="docs/design"
TARGET="docs/capstone"

# Portable in-place edit (BSD sed needs an -i argument; GNU sed does not).
rewrite() {
  sed 's|docs/design|docs/capstone|g' "$1" > "$1.capstone-tmp" \
    && mv "$1.capstone-tmp" "$1"
}

# 0. Retroactive migration. Only when the new tree does not exist yet —
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
  echo "note: both $LEGACY and $TARGET exist — not merging; $TARGET wins"
fi

# 1. config, at the fixed path
FILE="$TARGET/capstone.json"
mkdir -p "$TARGET"
if [ -f "$FILE" ]; then
  echo "exists: $FILE"
else
  cat > "$FILE" <<'EOF'
{
  "expertise": null,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en",
  "pipeline": null
}
EOF
  echo "created: $FILE"
fi

# 2. the docs area's ignore list
mkdir -p "$DOCS_DIR"
IGNORE="$DOCS_DIR/.gitignore"
if [ -f "$IGNORE" ]; then
  echo "exists: $IGNORE"
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
changelog.md
EOF
  echo "created: $IGNORE"
fi

# 3. Retroactive untracking. A repo that committed these before the
#    ignore list existed keeps tracking them — .gitignore only affects
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
