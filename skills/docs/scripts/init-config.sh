#!/usr/bin/env bash
# Creates docs/capstone/capstone.json with all default settings if absent,
# and the docs area's .gitignore covering capstone's local-only outputs.
# The config path is fixed regardless of docs_dir (see core.md); the
# .gitignore goes in the docs area, which $1 may relocate.
# Idempotent: never overwrites either file.
# Usage: init-config.sh [docs_dir]
set -eu
DOCS_DIR="${1:-docs/capstone}"
FILE="docs/capstone/capstone.json"
mkdir -p "docs/capstone"
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
