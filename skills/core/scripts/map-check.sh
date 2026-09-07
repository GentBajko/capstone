#!/usr/bin/env bash
# The script half of `map check` (protocols/map.md, "check"): parts 1
# (staleness), 7 (unfolded changelog.d/ fragments, informational) and 8
# (schema: frontmatter keys, required headings in their required order,
# table columns, the interfaces chapter's edge rows - site present,
# site tracked, payload section present and non-empty, schema resolving
# to a 02-models.md entity - and secret-shaped strings). What each kind
# of file owes comes from ../references/schema.txt, one record per
# output type, read at runtime. Prints the same tables the protocol
# describes and ends with
# exactly one verdict line, `MAP CHECK: current` or
# `MAP CHECK: stale (<N> findings)`, which templates/capstone-map-check.yml
# greps. Exit 0 on current, 1 on stale, 2 on a usage error. No model, no
# API key, no writes. The model half (parts 2-6) prints its own line,
# `MAP REVIEW:`, and never restates this one.
# Every script here is bash, on every platform: on Windows that means
# Git Bash. bash 3.2 (macOS default) is the floor: no mapfile, no
# associative arrays, no ${var,,}. POSIX-portable grep/sed/awk only: no
# GNU-only \| or \b, no sort -V, no sed -i without a suffix.
# set -u, never set -e: a failing git command must still reach the
# verdict line.
# Deterministic: two runs on one tree print identical bytes (every list
# is sorted under LC_ALL=C; no timestamps). CRLF files (a Windows
# checkout with autocrlf) are read as LF: a trailing \r is dropped from
# frontmatter, headings and table rows before comparison.
# Usage: map-check.sh [docs_dir ...]   (default docs/capstone)
#        map-check.sh --headings | --patterns | --schema | -h
set -u

PLUGIN_ROOT="$(cd "$(dirname "$0")/../../.." 2>/dev/null && pwd -P)"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd -P)"
# /nonexistent when HOME is unset (a bare container, a cron job): under
# set -u a bare $HOME would abort the run before the verdict line.
GLOBAL_DIR="${CAPSTONE_GLOBAL_DIR:-${CLAUDE_CONFIG_DIR:-${HOME:-/nonexistent}/.claude}}"

TOPICS='architecture models conventions data-flow dependencies testing operations glossary interfaces'

# references/schema.txt is the definition of every output shape this
# pass checks: which frontmatter keys a file owes, which `## ` headings
# it carries and in which order, and which columns its tables need. It
# is read here rather than copied in, so the rule lives in the schema
# and in the prose beside it (references/topics.md and the protocol
# files) and nowhere else; lint-sync checks 15, 20 and 21 assert the
# two agree. Resolved from this script's own directory, the same way
# PLUGIN_ROOT above finds the plugin manifest. A schema that has moved
# or cannot be read costs the headings, tables and key lists and
# nothing else: the run says so on its header line, checks every file
# for `generated_date`, keeps the edge and secret passes, and reaches
# the same verdict line with the same exit code. A gate that dies
# because a reference file moved is worse than one that names what it
# skipped.
SCHEMA_DIR="$(cd "$SCRIPT_DIR/../references" 2>/dev/null && pwd -P)"
SCHEMA_FILE="${SCHEMA_DIR:-$SCRIPT_DIR/../references}/schema.txt"
SCHEMA_TEXT=""
SCHEMA_OK=0
if [ -f "$SCHEMA_FILE" ] && [ -r "$SCHEMA_FILE" ]; then
  SCHEMA_TEXT=$(cat "$SCHEMA_FILE" 2>/dev/null) && SCHEMA_OK=1
fi
SCHEMA_MATCHES=""

# Secret-shaped strings (brief P8), `name=ERE` per line. Spelled
# identically in quarry's src/secrets.rs; `--patterns` prints them for
# that comparison. Findings name the pattern, never the matched text.
SECRET_PATTERNS='aws-access-key=AKIA[0-9A-Z]{16}
github-token=gh[pousr]_[A-Za-z0-9]{36,}
slack-token=xox[abprs]-[A-Za-z0-9-]{10,}
stripe-key=sk_(live|test)_[A-Za-z0-9]{16,}
google-api-key=AIza[0-9A-Za-z_-]{35}
private-key=-----BEGIN [A-Z ]*PRIVATE KEY-----'

# The empty-input hash. content_hash values written by 6.1 and earlier
# came from a `git ls-tree` recipe that does not expand wildcards, so
# every wildcard-covered chapter carries this constant; it is treated
# as absent.
EMPTY_HASH='e69de29bb2d1'

# the field separator of every parsed-row helper below. Not a tab: a
# tab is IFS whitespace, so `read` would collapse two of them into one
# and shift every field after an empty one - exactly the case a row
# with no `site` produces.
SEP=$(printf '\001')
# the docs area part 8 is reading, so an interfaces row's `schema` can
# be resolved against the models chapter beside it
DOCS_ABS=""

# Skipped entirely (brief P10): never stamped, or local working state.
# Matched on the path relative to docs_dir. The index is skipped for
# stamps, headings and sites but still secret-scanned (see run_dir).
# uiux/preview.html is the design preview protocols/uiux.md Phase D'
# writes: gitignored, no frontmatter, no schema record, and a rendering
# of 02-system.md rather than a page of its own.
is_skipped() {
  case "$1" in
    changelog*.md|changelog.d/*|*-interview.md|*/*-interview.md|features/*|review.md|be-review.md|fe-review.md|capstone.json|.gitignore|uiux/preview.html) return 0 ;;
  esac
  return 1
}

usage() {
  cat <<'EOF'
map-check.sh [docs_dir ...]     run parts 1, 7, 8 over each docs area (default: docs/capstone)
map-check.sh --headings         print the schema's required-headings list, one topic per line
map-check.sh --patterns         print the embedded secret patterns, name<TAB>regex per line
map-check.sh --schema           print the resolved schema path and its record count
map-check.sh -h | --help        usage
EOF
}

die_usage() { echo "map-check: $*" >&2; usage >&2; exit 2; }

# One schema line is `<field><space><value>`, with the value running to
# the end of the line so a heading list may hold spaces, `&` and `|`.
# A line whose first character is `#` is a comment and a blank line ends
# a record. These three readers are the only place the format is parsed.

# schema_types: every `type` id, in file order
schema_types() {
  printf '%s\n' "$SCHEMA_TEXT" | awk '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    { key = line; sub(/[ \t].*$/, "", key)
      val = line; sub(/^[^ \t]*[ \t]*/, "", val); sub(/[ \t]+$/, "", val) }
    key == "type" && val != "" { print val }'
}

# schema_pairs: `<type><SEP><glob>` per `match` line, in file order
schema_pairs() {
  printf '%s\n' "$SCHEMA_TEXT" | awk -v S="$SEP" '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    { key = line; sub(/[ \t].*$/, "", key)
      val = line; sub(/^[^ \t]*[ \t]*/, "", val); sub(/[ \t]+$/, "", val) }
    key == "type" { t = val; next }
    key == "match" && t != "" && val != "" { print t S val }'
}

# schema_field type field: that record's values for that field, one per
# line, in the order the record spells them
schema_field() {
  printf '%s\n' "$SCHEMA_TEXT" | awk -v want="$1" -v f="$2" '
    { sub(/\r$/, ""); line = $0 }
    line ~ /^#/ { next }
    { key = line; sub(/[ \t].*$/, "", key)
      val = line; sub(/^[^ \t]*[ \t]*/, "", val); sub(/[ \t]+$/, "", val) }
    key == "type" { inr = (val == want); next }
    inr && key == f && val != "" { print val }'
}

# schema_type_for relpath: the first record whose glob fits the path,
# empty when none does. The glob is unquoted on purpose - that is what
# makes `case` read it as a pattern.
schema_type_for() {
  local rel="$1" t g
  [ "$SCHEMA_OK" -eq 1 ] || return 0
  while IFS="$SEP" read -r t g; do
    [ -n "$t" ] && [ -n "$g" ] || continue
    case "$rel" in $g) printf '%s\n' "$t"; return 0 ;; esac
  done <<< "$SCHEMA_MATCHES"
  return 0
}

print_headings() {
  local t h
  if [ "$SCHEMA_OK" -eq 0 ]; then
    echo "schema: $SCHEMA_FILE unreadable; no headings to print" >&2
    return 0
  fi
  for t in $TOPICS; do
    h=$(schema_field "chapter-$t" head | head -1)
    [ -n "$h" ] || continue
    printf '%s: %s\n' "$t" "$h"
  done
}

print_schema() {
  local n
  if [ "$SCHEMA_OK" -eq 0 ]; then
    printf 'schema: %s unreadable\nrecords: 0\n' "$SCHEMA_FILE"
    return 0
  fi
  n=$(schema_types | grep -c .)
  printf 'schema: %s\nrecords: %s\n' "$SCHEMA_FILE" "$n"
}

print_patterns() {
  printf '%s\n' "$SECRET_PATTERNS" | awk -F= '{print $1 "\t" substr($0, length($1)+2)}'
}

plugin_version() {
  [ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ] || return 0
  sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -1
}

# version_lt a b: true when a < b on the first three numeric components
version_lt() {
  local a b i x y
  a=$(printf '%s' "$1" | tr -cd '0-9.')
  b=$(printf '%s' "$2" | tr -cd '0-9.')
  for i in 1 2 3; do
    x=$(printf '%s\n' "$a" | awk -F. -v i="$i" '{print $i}' | tr -cd '0-9')
    y=$(printf '%s\n' "$b" | awk -F. -v i="$i" '{print $i}' | tr -cd '0-9')
    [ -n "$x" ] || x=0
    [ -n "$y" ] || y=0
    [ "$x" -lt "$y" ] && return 0
    [ "$x" -gt "$y" ] && return 1
  done
  return 1
}

# absolute, symlink-resolved path; a missing leaf keeps its basename
abspath() {
  local p="${1%/}" d b
  [ -n "$p" ] || p="/"
  if [ -d "$p" ]; then
    (cd "$p" 2>/dev/null && pwd -P)
    return
  fi
  d=$(dirname "$p"); b=$(basename "$p")
  if [ -d "$d" ]; then
    printf '%s/%s\n' "$(cd "$d" && pwd -P)" "$b"
  else
    printf '%s\n' "$p"
  fi
}

# the block between the first `---` line and the next; empty without one.
# A trailing \r (CRLF checkout) is stripped so the fences still match.
frontmatter_of() {
  awk '{ sub(/\r$/, "") } NR==1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

# fm_value fm key: the scalar value, one pair of surrounding quotes stripped
fm_value() {
  local v
  v=$(printf '%s\n' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1)
  v=$(printf '%s' "$v" | sed -e 's/[[:space:]]*$//')
  case "$v" in
    \"*\") v=${v#\"}; v=${v%\"} ;;
    \'*\') v=${v#\'}; v=${v%\'} ;;
  esac
  printf '%s\n' "$v"
}

# paths_covered entries, one per line, block form and inline list form
fm_globs() {
  printf '%s\n' "$1" | awk -v q="'" '
    /^paths_covered:[[:space:]]*\[/ {
      s = $0; sub(/^paths_covered:[[:space:]]*\[/, "", s); sub(/\].*$/, "", s)
      n = split(s, a, ",")
      for (i = 1; i <= n; i++) {
        g = a[i]; gsub(/^[ \t]+|[ \t]+$/, "", g)
        gsub("^[\"" q "]|[\"" q "]$", "", g)
        if (g != "") print g
      }
      next
    }
    /^paths_covered:/ { inlist = 1; next }
    inlist && /^[ \t]+-[ \t]*/ {
      g = $0; sub(/^[ \t]+-[ \t]*/, "", g); gsub(/[ \t]+$/, "", g)
      gsub("^[\"" q "]|[\"" q "]$", "", g)
      if (g != "") print g
      next
    }
    inlist { inlist = 0 }'
}

# known_as_form fm: `missing`, `list` or `scalar` for the interfaces
# chapter's known_as key (references/topics.md). A list is either
# bracketed (`known_as: [a, b]`, `known_as: []`) or an empty value with a
# `- ` block under it. Anything else is a scalar, which quarry's
# known_as_of reports as `known_as is not a list` and then registers no
# aliases at all, so every consumer naming this repo by an alias loses
# its edge. A bare `known_as:` with no block is YAML null, a scalar there
# too.
known_as_form() {
  printf '%s\n' "$1" | awk '
    { sub(/\r$/, "") }
    done { next }
    /^known_as:[ \t]*\[/ { r = "list"; done = 1; next }
    /^known_as:[ \t]*$/ { r = "scalar"; block = 1; next }
    /^known_as:/ { r = "scalar"; done = 1; next }
    block { if ($0 ~ /^[ \t]*-([ \t]|$)/) r = "list"; done = 1; next }
    END { if (r == "") r = "missing"; print r }'
}

# the frontmatter `site:` mirror (interfaces_frontmatter: true)
fm_sites() {
  printf '%s\n' "$1" | sed -n 's/^[[:space:]]*site:[[:space:]]*//p' | sed -e 's/[[:space:]]*$//' -e 's/`//g'
}

# edge_items: `dir<TAB>kind<TAB>name<TAB>site<TAB>schema` per row, from a
# frontmatter fragment already narrowed to the block that holds the
# `produces:`/`consumes:` keys. Both list forms references/topics.md
# allows are read: a flow mapping (`- { kind: sqs, name: x, site: y }`)
# and a block mapping (`- kind: sqs` with `name:` on the lines under
# it). One pair of surrounding quotes is stripped from a scalar. A
# comma inside a quoted flow value would split the row, which no
# contract name capstone writes carries; the block form is the way out
# for one that does. `to` and `from` are read only so that a row
# carrying them still ends where it should - this pass never reports
# on them, they are the user's and quarry's.
edge_items() {
  awk '
    BEGIN { S = sprintf("%c", 1) }
    function unq(s) {
      gsub(/^[ \t]+|[ \t]+$/, "", s)
      if (s ~ /^".*"$/) return substr(s, 2, length(s) - 2)
      if (s ~ /^\047.*\047$/) return substr(s, 2, length(s) - 2)
      return s
    }
    function setkv(k, v) {
      if (k == "kind") kind = v
      else if (k == "name") name = v
      else if (k == "site") site = v
      else if (k == "schema") schema = v
    }
    function emit() {
      if (open) print dir S kind S name S site S schema
      open = 0; kind = ""; name = ""; site = ""; schema = ""
    }
    function pair(s,   p, k) {
      p = index(s, ":")
      if (p == 0) return
      k = substr(s, 1, p - 1); gsub(/^[ \t]+|[ \t]+$/, "", k)
      setkv(tolower(k), unq(substr(s, p + 1)))
    }
    function flow(s,   n, a, i) {
      sub(/^[ \t]*\{[ \t]*/, "", s); sub(/[ \t]*\}[ \t]*$/, "", s)
      n = split(s, a, ",")
      for (i = 1; i <= n; i++) pair(a[i])
    }
    { sub(/\r$/, "") }
    /^[ \t]*#/ { next }
    /^[ \t]*produces:[ \t]*$/ { emit(); dir = "produces"; next }
    /^[ \t]*consumes:[ \t]*$/ { emit(); dir = "consumes"; next }
    dir == "" { next }
    /^[ \t]*-[ \t]*\{/ { emit(); open = 1; s = $0; sub(/^[ \t]*-[ \t]*/, "", s); flow(s); next }
    /^[ \t]*-[ \t]*(kind|name|site|schema|to|from)[ \t]*:/ {
      emit(); open = 1; s = $0; sub(/^[ \t]*-[ \t]*/, "", s); pair(s); next }
    open && /^[ \t]*(kind|name|site|schema|to|from)[ \t]*:/ { pair($0); next }
    { emit(); dir = "" }
    END { emit() }'
}

# edges_of fm: the frontmatter edge rows. references/topics.md makes the
# `edges:` block canonical, with `produces:`/`consumes:` under it; a
# page written before the block existed carries those two keys at the
# top level instead, and quarry reads whichever it finds first, so this
# reads the block alone when there is one.
edges_of() {
  if printf '%s\n' "$1" | grep -q '^edges:[[:space:]]*$'; then
    printf '%s\n' "$1" | awk '
      { sub(/\r$/, "") }
      inb && /^[^ \t]/ { inb = 0 }
      inb { print }
      /^edges:[ \t]*$/ { inb = 1 }' | edge_items
  else
    printf '%s\n' "$1" | edge_items
  fi
}

# table_edges file: the same rows read from the Produces and Consumes
# tables, for a page whose frontmatter carries no edge block at all.
# Columns are located by header name, fenced blocks are skipped,
# backticks and link syntax come off the cell, and an escaped pipe is
# parked as \001 so it never shifts a column - the rules site_cells and
# payload_gaps already apply. A `### ` heading closes the edge table.
table_edges() {
  awk '
    BEGIN { S = sprintf("%c", 1) }
    function cell(v) {
      gsub(/\001/, "|", v); gsub(/`/, "", v)
      while (match(v, /\[[^]]*\]\([^)]*\)/)) { m = substr(v, RSTART, RLENGTH); t = m
        sub(/^\[/, "", t); sub(/\].*$/, "", t)
        v = substr(v, 1, RSTART - 1) t substr(v, RSTART + RLENGTH) }
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/[ \t]+/, " ", v)
      if (v == "-") v = ""
      return v
    }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^###+ / { if (intable) { intable = 0 } done = 1; next }
    /^##[ \t]/ {
      s = $0; sub(/^##[ \t]*/, "", s); gsub(/^[ \t]+|[ \t]+$/, "", s)
      if (s == "Produces") dir = "produces"
      else if (s == "Consumes") dir = "consumes"
      else dir = ""
      intable = 0; done = 0; next }
    dir == "" { next }
    /^[ \t]*\|/ {
      if (done) next
      line = $0; gsub(/\\[|]/, "\001", line)
      if (!intable) { intable = 1; ck = 0; cn = 0; cs = 0; n = split(line, hd, "|")
        for (i = 1; i <= n; i++) { x = hd[i]; gsub(/^[ \t]+|[ \t]+$/, "", x); gsub(/`/, "", x)
          x = tolower(x)
          if (x == "kind") ck = i; else if (x == "name") cn = i
          else if (x == "site") cs = i }
        next }
      if (line ~ /^[| \t:-]+$/) next
      n = split(line, c, "|")
      print dir S cell(ck ? c[ck] : "") S cell(cn ? c[cn] : "") S cell(cs ? c[cs] : "") S ""
      next }
    intable { intable = 0; done = 1 }' "$1"
}

# payload_bodies file: one line per `### <Name>` section under a
# Produces or Consumes heading, `name<TAB>form<TAB>model`. `form` is
# `table` when a table row follows the heading, `model` when a `Model:`
# line does, `both` when the section carries both (topics.md: the table
# wins, and the reference is still checked), and `empty` when it
# carries neither, which is the section quarry check cannot compare.
# Only a space after the hashes opens a heading, the way quarry's
# frontmatter::heading_of demands.
payload_bodies() {
  awk '
    BEGIN { S = sprintf("%c", 1) }
    function flush(   f) {
      if (h != "") {
        f = (tab && mdl) ? "both" : (tab ? "table" : (mdl ? "model" : "empty"))
        print h S f S mv }
      h = ""; tab = 0; mdl = 0; mv = ""
    }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^###+ / {
      flush()
      if (want) { s = $0; sub(/^#+[ \t]*/, "", s); sub(/[ \t]*\{#[^}]*\}$/, "", s)
        gsub(/^[ \t]+|[ \t]+$/, "", s); gsub(/[ \t]+/, " ", s); h = s }
      next }
    /^##[ \t]/ {
      flush()
      s = $0; sub(/^##[ \t]*/, "", s); gsub(/^[ \t]+|[ \t]+$/, "", s)
      want = (s == "Produces" || s == "Consumes"); next }
    h == "" { next }
    /^[ \t]*\|/ { tab = 1; next }
    /^[ \t]*Model:[ \t]*/ {
      mdl = 1; s = $0; sub(/^[ \t]*Model:[ \t]*/, "", s); gsub(/`/, "", s)
      gsub(/^[ \t]+|[ \t]+$/, "", s); mv = s; next }
    END { flush() }' "$1"
}

# model_known docs_dir entity: this docs area's models chapter holds a
# `### <Entity>` section for it (references/topics.md, Fields and
# types). A trailing `[]` is a list of the same entity and changes
# nothing. Matching follows quarry: a trailing `{#anchor}` dropped,
# runs of whitespace collapsed, case folded, exact heading first and
# then `<entity> (` as a prefix. A split chapter (02-models-<part>.md,
# map.md Phase 3 step 8) counts too.
model_known() {
  local d="$1" e="$2" f
  e=$(printf '%s' "$2" | sed -e 's/\[\]$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [ -n "$e" ] || return 1
  for f in "$d"/02-models.md "$d"/02-models-*.md; do
    [ -f "$f" ] || continue
    awk -v want="$e" '
      { sub(/\r$/, "") }
      /^[ \t]*(```|~~~)/ { fence = !fence; next }
      fence { next }
      /^###[ \t]/ {
        h = $0; sub(/^#+[ \t]*/, "", h); sub(/[ \t]*\{#[^}]*\}$/, "", h)
        gsub(/^[ \t]+|[ \t]+$/, "", h); gsub(/[ \t]+/, " ", h)
        lh = tolower(h); lw = tolower(want)
        if (lh == lw || index(lh, lw " (") == 1) { found = 1; exit } }
      END { exit(found ? 0 : 1) }' "$f" && return 0
  done
  return 1
}

# head_findings file heads: one finding per required `## ` heading the
# file does not carry (`## <H>`) and per heading that sits ahead of one
# the schema puts before it
# (`## <H> out of order (before ## <Prev>)`), in schema order. Extra
# headings are never a finding. Only two hashes followed by a space or a
# tab open a heading here, so a `### ` payload section never satisfies a
# chapter section; fenced blocks are skipped, so a chapter documenting
# the template satisfies nothing by quoting it. A trailing \r and
# surrounding whitespace come off before comparing, the way every other
# reader in this file treats a CRLF checkout.
head_findings() {
  awk -v req="$2" '
    BEGIN { n = split(req, R, "|") }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^##[ \t]/ {
      s = substr($0, 3); gsub(/^[ \t]+|[ \t]+$/, "", s); gsub(/[ \t]+/, " ", s)
      if (s != "" && !(s in pos)) { seq++; pos[s] = seq }
      next }
    END {
      prev = ""; prevpos = 0
      for (i = 1; i <= n; i++) {
        h = R[i]
        if (h == "") continue
        if (!(h in pos)) { print "## " h; continue }
        if (prevpos > 0 && pos[h] < prevpos)
          print "## " h " out of order (before ## " prev ")"
        prev = h; prevpos = pos[h]
      }
    }' "$1"
}

# table_finding file heading columns: the columns the first table under
# `## <heading>` does not carry. Columns are matched by lowercased
# header name, never by position, and a column the schema does not name
# is free. A heading the file does not carry produces nothing here -
# head_findings already reported it, and one gap is one finding. A
# heading with no table under it produces nothing either: references/
# topics.md tells a deep-dive to write "None found" plus where it
# looked rather than omit a section, so an empty Produces or Consumes
# is the sanctioned answer and not a defect.
table_finding() {
  awk -v want="$2" -v cols="$3" '
    function norm(v) {
      gsub(/`/, "", v); gsub(/\001/, "|", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/[ \t]+/, " ", v); return v }
    BEGIN { nc = split(cols, C, "|") }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^##[ \t]/ {
      s = norm(substr($0, 3))
      if (inw) { inw = 0; done = 1 }
      if (!done && s == want) { inw = 1; found = 1 }
      next }
    !inw { next }
    /^[ \t]*\|/ {
      if (hdr) next
      line = $0; gsub(/\\[|]/, "\001", line)
      if (line ~ /^[| \t:-]+$/) next
      hdr = 1
      n = split(line, h, "|")
      for (i = 1; i <= n; i++) { x = norm(h[i]); if (x != "") seen[tolower(x)] = 1 }
      next }
    END {
      if (!found || !hdr) exit 0
      for (i = 1; i <= nc; i++)
        if (C[i] != "" && !(tolower(C[i]) in seen)) print "table " want " missing " C[i]
    }' "$1"
}

# subtable_finding file heading level columns: the same column test
# applied to every heading at <level> under `## <heading>`, which is the
# shape `head` cannot express - the models chapter's one `### <Entity>`
# section per entity, each holding its own field table. The finding
# names the sub-heading, so a reader is sent to the section rather than
# the chapter.
subtable_finding() {
  awk -v want="$2" -v lvl="$3" -v cols="$4" '
    function norm(v) {
      gsub(/`/, "", v); gsub(/\001/, "|", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/[ \t]+/, " ", v); return v }
    function hlevel(   n) { n = 0; while (substr($0, n + 1, 1) == "#") n++; return n }
    function flush(   i) {
      if (sh != "")
        for (i = 1; i <= nc; i++)
          if (C[i] != "" && !(tolower(C[i]) in seen)) print "table " sh " missing " C[i]
      sh = ""; hdr = 0; split("", seen)
    }
    BEGIN { nc = split(cols, C, "|") }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^#+[ \t]/ {
      L = hlevel()
      if (L <= lvl) flush()
      if (L == 2) {
        s = norm(substr($0, 3))
        if (inw) { inw = 0; done = 1 }
        if (!done && s == want) inw = 1
        next }
      if (inw && L == lvl) sh = norm(substr($0, lvl + 1))
      next }
    !inw { next }
    sh == "" { next }
    /^[ \t]*\|/ {
      if (hdr) next
      line = $0; gsub(/\\[|]/, "\001", line)
      if (line ~ /^[| \t:-]+$/) next
      hdr = 1
      n = split(line, h, "|")
      for (i = 1; i <= n; i++) { x = norm(h[i]); if (x != "") seen[tolower(x)] = 1 }
      next }
    END { flush() }' "$1"
}

# list_docs docs_dir index: the files to check, absolute, one per line -
# index links in file order (a directory row expands to its *.md files),
# then every other *.md under docs_dir, deduped, skip list applied
list_docs() {
  local d="$1" idx="$2" idxdir t p
  idxdir=$(dirname "$idx")
  {
    if [ -f "$idx" ]; then
      grep -o '](\([^)]*\))' "$idx" | sed -e 's/^](//' -e 's/)$//' | while IFS= read -r t; do
        case "$t" in http*|'#'*|/*|'') continue ;; esac
        t=${t%%#*}
        [ -n "$t" ] || continue
        case "$t" in
          */) p="$idxdir/${t%/}"
              [ -d "$p" ] && find "$(abspath "$p")" -name '*.md' | LC_ALL=C sort ;;
          *.md) p="$idxdir/$t"
              [ -f "$p" ] && abspath "$p" ;;
        esac
      done
    fi
    find "$d" -name '*.md' | LC_ALL=C sort
  } | awk '!seen[$0]++' | while IFS= read -r p; do
    [ "$p" = "$idx" ] && continue
    case "$p" in "$d"/*) ;; *) continue ;; esac
    is_skipped "${p#"$d"/}" && continue
    printf '%s\n' "$p"
  done
}

# list_non_md docs_dir: every non-markdown file under the docs area,
# relative to it, NUL-delimited, skip list applied - the secret scan's
# second pass. A .env.example or a compose excerpt beside the chapters
# ships like any other file and the schema pass never opens it. Inside
# git only tracked files count (an untracked scratch file is not
# shipped); `git ls-files` is run with -C in the docs dir so a path
# holding glob metacharacters is never read as a pathspec, and with -z
# so git never C-quotes the name. Without -z a tracked name outside
# plain ASCII comes back escaped (`uni-` plus an e-acute reads as the
# literal `"uni-\303\251.env"`), the `[ -f ]` test below drops it
# without a word, and a credential in a shipped file is never scanned;
# -z covers the same for a name holding a quote, a backslash or a
# newline. The output is NUL-delimited for the same reason: a newline
# in a tracked name would otherwise split into two paths the caller
# cannot open. Outside git the `find` fallback is newline-delimited, so
# there a name holding one is dropped. `git ls-files` emits index
# order, which is byte order already, so only the find branch is
# sorted.
list_non_md() {
  local d="$1" p
  {
    if [ "$IN_GIT" -eq 1 ]; then
      git -C "$d" ls-files -z 2>/dev/null
    else
      (cd "$d" 2>/dev/null && find . -type f | sed 's|^\./||' \
        | LC_ALL=C sort | tr '\n' '\0')
    fi
  } | while IFS= read -r -d '' p; do
    [ -n "$p" ] || continue
    case "$p" in *.md) continue ;; esac
    is_skipped "$p" && continue
    [ -f "$d/$p" ] || continue
    printf '%s\0' "$p"
  done
}

# git helpers; every one runs from the repo root so :(top) globs and
# plain relative globs both anchor there
changed_since() {
  local stamp="$1"; shift
  { git -C "$ROOT" diff --name-only "$stamp" -- "$@" 2>/dev/null
    git -C "$ROOT" status --porcelain -- "$@" 2>/dev/null | cut -c4-; } | LC_ALL=C sort -u
}
# core.md's stamps rule, byte for byte (lint-sync check 15b pins it)
tree_hash() {
  (cd "$ROOT" && git ls-files -s --full-name -- "$@" 2>/dev/null) | git hash-object --stdin | cut -c1-12
}
has_source() { [ -n "$(git -C "$ROOT" ls-files -- "$@" 2>/dev/null | head -1)" ]; }
is_dirty() { [ -n "$(git -C "$ROOT" status --porcelain -- "$@" 2>/dev/null | head -1)" ]; }
stamp_reachable() { git -C "$ROOT" cat-file -e "$1^{commit}" >/dev/null 2>&1; }

# the Site column of every table in the file: fenced blocks skipped,
# backticks and link syntax stripped, `-` and empty cells dropped. A
# markdown-escaped pipe (`\|`) inside a cell is parked as \001 before
# the split so it never shifts the column, then restored.
site_cells() {
  awk '
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^[ \t]*\|/ {
      gsub(/\\[|]/, "\001", $0)
      if (!intable) { intable = 1; col = 0; n = split($0, h, "|")
        for (i = 1; i <= n; i++) { x = h[i]; gsub(/^[ \t]+|[ \t]+$/, "", x); gsub(/`/, "", x)
          if (tolower(x) == "site") col = i }
        next }
      if ($0 ~ /^[| \t:-]+$/) next
      if (col) { n = split($0, c, "|"); v = c[col]; gsub(/\001/, "|", v); gsub(/`/, "", v)
        while (match(v, /\[[^]]*\]\([^)]*\)/)) { m = substr(v, RSTART, RLENGTH); t = m
          sub(/^\[/, "", t); sub(/\].*$/, "", t)
          v = substr(v, 1, RSTART - 1) t substr(v, RSTART + RLENGTH) }
        gsub(/^[ \t]+|[ \t]+$/, "", v); if (v != "" && v != "-") print v }
      next }
    { intable = 0 }' "$1"
}

# payload_gaps file: the Name cells of an interfaces page's Produces and
# Consumes tables that have no `### <Name>` payload section under the
# same `## ` heading (references/topics.md, "Payload sections" - the
# tables `quarry check` compares). One table per section, the Name
# column located by header name, fenced blocks skipped, backticks and
# link syntax stripped from the cell, escaped pipes parked as \001 so
# they never shift a column. A heading matches its row exactly or as the row plus ` (`,
# which is the version suffix topics.md allows. Both sides are normalised
# the way quarry's frontmatter::normalize_heading normalises a heading: a
# trailing `{#anchor}` is dropped, runs of whitespace collapse to one
# space, and the comparison folds case. A `### ` heading also ends the
# edge table, so a page that writes one with no blank line around it
# never has its payload rows read as more edge rows. Backticks, link
# syntax and escaped pipes are stripped from the cell only; the heading
# is taken as written, because quarry reads the cell out of a table and
# the heading through normalize_heading, which strips none of the three.
# A backticked heading is therefore a finding here and no payload table
# for quarry. Only a space after the hashes opens a heading, the way
# quarry's frontmatter::heading_of demands; the `## ` rule below still
# accepts a tab, since it only scopes this script's own search.
payload_gaps() {
  awk '
    function flush(   i, j, ok) {
      for (i = 1; i <= nn; i++) {
        ok = 0
        for (j = 1; j <= nh; j++)
          if (lheads[j] == lnames[i] || index(lheads[j], lnames[i] " (") == 1) { ok = 1; break }
        if (!ok) print names[i]
      }
      nn = 0; nh = 0; col = 0; intable = 0; done = 0
    }
    { sub(/\r$/, "") }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^###+ / {
      if (intable) { intable = 0; done = 1 }
      if (want) { h = $0; sub(/^#+[ \t]*/, "", h); gsub(/^[ \t]+|[ \t]+$/, "", h)
        sub(/[ \t]*\{#[^}]*\}$/, "", h); gsub(/[ \t]+/, " ", h)
        if (h != "") { heads[++nh] = h; lheads[nh] = tolower(h) } }
      next }
    /^##[ \t]/ {
      flush()
      s = $0; sub(/^##[ \t]*/, "", s); gsub(/^[ \t]+|[ \t]+$/, "", s)
      want = (s == "Produces" || s == "Consumes"); sect++
      next }
    !want { next }
    /^[ \t]*\|/ {
      if (done) next
      line = $0; gsub(/\\[|]/, "\001", line)
      if (!intable) { intable = 1; col = 0; n = split(line, hd, "|")
        for (i = 1; i <= n; i++) { x = hd[i]; gsub(/^[ \t]+|[ \t]+$/, "", x); gsub(/`/, "", x)
          if (tolower(x) == "name") col = i }
        next }
      if (line ~ /^[| \t:-]+$/) next
      if (col) { n = split(line, c, "|"); v = c[col]; gsub(/\001/, "|", v); gsub(/`/, "", v)
        while (match(v, /\[[^]]*\]\([^)]*\)/)) { m = substr(v, RSTART, RLENGTH); t = m
          sub(/^\[/, "", t); sub(/\].*$/, "", t)
          v = substr(v, 1, RSTART - 1) t substr(v, RSTART + RLENGTH) }
        gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/[ \t]+/, " ", v)
        if (v != "" && v != "-" && !seen[sect, v]++) { names[++nn] = v; lnames[nn] = tolower(v) } }
      next }
    intable { intable = 0; done = 1 }
    END { flush() }' "$1"
}

# the path before a trailing :line or :from-to
site_path() { printf '%s\n' "$1" | sed 's/:[0-9]\{1,\}\(-[0-9]\{1,\}\)\{0,1\}$//'; }

# site_tracked path: the path names one tracked file. --error-unmatch
# answers "does this pathspec match anything"; the exact-line test then
# demands the match be the path itself, so a cell holding a wildcard
# (`src/*.rs`) or a tracked directory (`src/api`) is a finding. Quarry
# tests the same cells for membership in the blob set, so both sides
# have to name a file.
site_tracked() {
  git -C "$ROOT" ls-files --error-unmatch -- "$1" >/dev/null 2>&1 || return 1
  git -C "$ROOT" -c core.quotepath=off ls-files --full-name -- "$1" | grep -qFx -- "$1"
}

# check_part1 disp fm globs: one staleness row for a stamped file
check_part1() {
  local disp="$1" fm="$2" globs="$3"
  local mode stamp ver hash changed verdict fallback now n g
  local -a ga
  ga=()
  while IFS= read -r g; do [ -n "$g" ] && ga+=("$g"); done <<< "$globs"
  mode=$(fm_value "$fm" mode)
  stamp=$(fm_value "$fm" generated_at_commit)
  ver=$(fm_value "$fm" capstone_version)
  hash=$(fm_value "$fm" content_hash)
  [ "$hash" = "$EMPTY_HASH" ] && hash=""
  changed="-"; verdict=""; fallback=""
  if [ ${#ga[@]} -eq 0 ]; then
    # No globs, so there is nothing to diff and staleness is not a
    # question this page can answer. Which capstone wrote it still is,
    # and for a page no refresh path regenerates that is the only signal
    # there will ever be.
    if [ -n "$PLUGIN_VERSION" ] && version_lt "$ver" "$PLUGIN_VERSION"; then
      verdict="written by an older capstone"
    else
      verdict=current
    fi
  elif [ "$IN_GIT" -eq 0 ]; then
    verdict="unknowable (not a git repo)"
  elif [ "$mode" = prescriptive ]; then
    if has_source "${ga[@]}"; then verdict="prescriptive, pending first observation"
    else verdict=current; fi
  else
    if [ -n "$stamp" ] && stamp_reachable "$stamp"; then
      n=$(changed_since "$stamp" "${ga[@]}" | grep -c .)
      changed=$n
      [ "$n" -gt 0 ] && verdict=stale
    elif [ -n "$hash" ]; then
      now=$(tree_hash "${ga[@]}")
      if [ "$now" != "$hash" ] || is_dirty "${ga[@]}"; then verdict=stale; fi
    else
      fallback="stamp unreachable"
    fi
    # precedence: stale (set above) -> stamp unreachable -> written by an
    # older capstone -> current. An unstamped file says nothing about the
    # version it was written by, so the honest verdict is the missing stamp.
    if [ -z "$verdict" ]; then
      if [ -n "$fallback" ]; then
        verdict="$fallback"
      elif [ -z "$ver" ] || { [ -n "$PLUGIN_VERSION" ] && version_lt "$ver" "$PLUGIN_VERSION"; }; then
        verdict="written by an older capstone"
      else
        verdict=current
      fi
    fi
  fi
  # A page with no globs cannot be stale against code, and no refresh
  # path regenerates one: `standards.md` and every interview-derived
  # scenario or screen are rewritten by re-running their own stage. The
  # version gap is worth showing and worth nobody's failed build, so it
  # is reported the way part 7 reports a waiting fragment.
  case "$verdict" in
    current|"unknowable (not a git repo)") ;;
    *)
      if [ ${#ga[@]} -eq 0 ]; then
        verdict="$verdict (informational)"
      else
        FINDINGS=$((FINDINGS + 1)); P1_FINDINGS=$((P1_FINDINGS + 1))
      fi
      ;;
  esac
  P1_ROWS="$P1_ROWS| $disp | ${stamp:--} | ${ver:--} | $changed | $verdict |
"
}

# check_part8 file disp fm globs record secrets_only: one schema row
# when the file has at least one item; each item is a finding. `record`
# is the schema type the path resolved to, empty for a file no record
# claims and for the non-markdown sweep.
check_part8() {
  local f="$1" disp="$2" fm="$3" globs="$4" record="$5" only_secrets="$6"
  local keys="" heads="" sites="" secrets="" mode cell p line name re seen k base items=0
  local rows="" models="" rowsites="" edir ekind ename esite eschema pname pform pmodel
  local hl opts spec col lvl older fmver
  mode=$(fm_value "$fm" mode)
  base=$(basename "$f")
  # A page written by an older capstone is measured against a template it
  # never saw, so its every heading would be reported at once. Part 1
  # names that page and its repair already; the section list is checked
  # again once the owning stage has rewritten it.
  older=0
  fmver=$(fm_value "$fm" capstone_version)
  if [ -n "$fmver" ] && [ -n "$PLUGIN_VERSION" ] && version_lt "$fmver" "$PLUGIN_VERSION"; then
    older=1
  fi
  if [ "$only_secrets" -eq 0 ]; then
    # keys!: owed on every page, inside git or out, prescriptive or not.
    # `known_as` is spelled in the schema like any other key and read
    # here by the rule topics.md sets for it: quarry registers no alias
    # at all when the value is a scalar, and says so only on `docs index
    # --force`, so this is the one gate that catches either shape.
    # Without a readable schema every page still owes its date.
    if [ "$SCHEMA_OK" -eq 1 ]; then
      hl=$(schema_field "$record" 'keys!' | tr ' ' '\n')
    elif [ "$record" = index ]; then
      hl=""
    else
      hl="generated_date"
    fi
    while IFS= read -r k; do
      [ -n "$k" ] || continue
      case "$k" in
        known_as)
          case "$(known_as_form "$fm")" in
            missing) keys="${keys:+$keys, }known_as"; items=$((items + 1)) ;;
            scalar) keys="${keys:+$keys, }known_as not a list"; items=$((items + 1)) ;;
          esac ;;
        *)
          if [ -z "$(fm_value "$fm" "$k")" ]; then
            keys="${keys:+$keys, }$k"; items=$((items + 1))
          fi ;;
      esac
    done <<< "$hl"
    # keys: the stamps only git can produce. A prescriptive page owes
    # none of them - it describes code that does not exist yet - and
    # outside git there is nothing to stamp against. `opt` waives its
    # keys on a page carrying no globs, which is how an interview's
    # output and the same file written by extraction are told apart.
    if [ "$SCHEMA_OK" -eq 1 ] && [ "$IN_GIT" -eq 1 ] && [ "$mode" != prescriptive ]; then
      opts=" $(schema_field "$record" opt | tr '\n' ' ') "
      while IFS= read -r k; do
        [ -n "$k" ] || continue
        if [ -z "$globs" ]; then
          case "$opts" in *" $k "*) continue ;; esac
        fi
        # paths_covered is read as a list, so its presence is whether
        # this run found any glob rather than whether a scalar follows
        # the colon
        if [ "$k" = paths_covered ]; then
          [ -n "$globs" ] && continue
        elif [ -n "$(fm_value "$fm" "$k")" ]; then
          continue
        fi
        keys="${keys:+$keys, }$k"; items=$((items + 1))
      done <<< "$(schema_field "$record" keys | tr ' ' '\n')"
    fi
    if [ "$SCHEMA_OK" -eq 1 ] && [ -n "$record" ] && [ "$older" -eq 0 ]; then
      hl=$(schema_field "$record" head | head -1)
      if [ -n "$hl" ]; then
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          heads="${heads:+$heads, }$line"; items=$((items + 1))
        done <<< "$(head_findings "$f" "$hl")"
      fi
      while IFS= read -r spec; do
        [ -n "$spec" ] || continue
        col=${spec#*:}; name=${spec%%:*}
        [ -n "$col" ] && [ "$col" != "$spec" ] || continue
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          heads="${heads:+$heads, }$line"; items=$((items + 1))
        done <<< "$(table_finding "$f" "$name" "$col")"
      done <<< "$(schema_field "$record" table)"
      while IFS= read -r spec; do
        [ -n "$spec" ] || continue
        name=${spec%%:*}; spec=${spec#*:}
        lvl=${spec%%:*}; col=${spec#*:}
        [ -n "$col" ] && [ -n "$lvl" ] && [ "$col" != "$lvl" ] || continue
        case "$lvl" in *[!0-9]*|'') continue ;; esac
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          heads="${heads:+$heads, }$line"; items=$((items + 1))
        done <<< "$(subtable_finding "$f" "$name" "$lvl" "$col")"
      done <<< "$(schema_field "$record" subtable)"
    fi
    case "$base" in
      09-interfaces.md|09-interfaces-*.md)
        # the edge rows: the frontmatter block when the page carries
        # one, else the tables (references/topics.md's precedence, the
        # order quarry reads them in).
        rows=$(edges_of "$fm")
        [ -n "$rows" ] || rows=$(table_edges "$f")
        # a row with no site cannot point at the code it describes.
        # Checked outside git and on a prescriptive chapter too, like
        # the payload sections below: it is text the page owes, not a
        # path the tree has to hold.
        rowsites=""
        while IFS="$SEP" read -r edir ekind ename esite eschema; do
          [ -n "$ekind$ename$esite$eschema" ] || continue
          if [ -z "$esite" ]; then
            sites="${sites:+$sites, }no site for ${ekind:--} ${ename:--}"
            items=$((items + 1))
          else
            rowsites="$rowsites$esite
"
          fi
        done <<< "$rows"
        if [ "$IN_GIT" -eq 1 ] && [ "$mode" != prescriptive ]; then
          seen="
"
          while IFS= read -r cell; do
            [ -n "$cell" ] || continue
            case "$seen" in *"
$cell
"*) continue ;; esac
            seen="$seen$cell
"
            p=$(site_path "$cell")
            [ -n "$p" ] || p="$cell"
            if ! site_tracked "$p"; then
              sites="${sites:+$sites, }site $cell"; items=$((items + 1))
            fi
          done <<< "$(site_cells "$f"; fm_sites "$fm"; printf '%s' "$rowsites")"
        fi
        # payload sections: a Produces or Consumes row without its
        # `### <Name>` section is the table quarry check cannot compare.
        # Checked outside git and on a prescriptive chapter too: the
        # section is text the page owes, not a path the tree has to hold.
        while IFS= read -r name; do
          [ -n "$name" ] || continue
          heads="${heads:+$heads, }### $name"; items=$((items + 1))
        done <<< "$(payload_gaps "$f")"
        # and a section that holds neither a field table nor a
        # `Model:` line leaves quarry check nothing to compare either.
        # Every model named, by a section or by a row's `schema`, has
        # to resolve to a `### <Entity>` in this docs area's
        # 02-models.md; each distinct name is reported once.
        models="
"
        while IFS="$SEP" read -r pname pform pmodel; do
          [ -n "$pname" ] || continue
          case "$pform" in
            empty)
              heads="${heads:+$heads, }payload ### $pname"; items=$((items + 1)) ;;
            model|both)
              # `<Entity>[]` is a list of the same entity, so the two
              # spellings are one reference and one finding
              pmodel=${pmodel%'[]'}
              [ -n "$pmodel" ] || continue
              case "$models" in *"
$pmodel
"*) continue ;; esac
              models="$models$pmodel
"
              model_known "$DOCS_ABS" "$pmodel" && continue
              heads="${heads:+$heads, }model $pmodel"; items=$((items + 1)) ;;
          esac
        done <<< "$(payload_bodies "$f")"
        while IFS="$SEP" read -r edir ekind ename esite eschema; do
          eschema=${eschema%'[]'}
          [ -n "$eschema" ] || continue
          case "$models" in *"
$eschema
"*) continue ;; esac
          models="$models$eschema
"
          model_known "$DOCS_ABS" "$eschema" && continue
          heads="${heads:+$heads, }model $eschema"; items=$((items + 1))
        done <<< "$rows" ;;
    esac
  fi
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    name=${line%%=*}; re=${line#*=}
    if grep -Eq -e "$re" "$f"; then secrets="${secrets:+$secrets, }secret: $name"; items=$((items + 1)); fi
  done <<< "$SECRET_PATTERNS"
  [ "$items" -gt 0 ] || return 0
  FINDINGS=$((FINDINGS + items)); P8_FINDINGS=$((P8_FINDINGS + items))
  P8_ROWS="$P8_ROWS| $disp | ${keys:--} | ${heads:--} | ${sites:--} | ${secrets:--} |
"
}

# part 7: changelog.d/ fragments with their keys, never counted
check_part7() {
  local d="$1" f key n=0
  echo
  echo "## 7. Unfolded fragments"
  echo
  # find + sort: bash glob order follows the caller's locale
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    n=$((n + 1))
    key=$(sed -n 's/^key:[[:space:]]*//p' "$f" | head -1 | tr -d '\r')
    if [ -n "$key" ]; then echo "- changelog.d/$(basename "$f"): key $key"
    else echo "- changelog.d/$(basename "$f"): no key line"; fi
  done <<< "$(find "$d/changelog.d" -name '*.md' 2>/dev/null | LC_ALL=C sort)"
  echo "unfolded fragments: $n (informational; any writing run folds them, so does doctor)"
}

# resolve_index docs_abs: the project's <docs_dir>/capstone.json
# index_file, then the global one, otherwise <docs_dir>/00-index.md.
# The project file sits inside the docs area it configures, so its
# candidate is honoured anywhere under this docs dir - a nested
# `index/00-index.md` is a legal layout, and a candidate that names no
# file is reported as `no index at <path>` rather than swapped for a
# fallback. The global file is machine-wide, so its candidate is
# honoured only when it names a file directly in this docs dir: the
# stock global `index_file` is `docs/capstone/00-index.md`, which must
# not become the index of a project whose docs area is `docs`.
resolve_index() {
  local d="$1" scope cfg v cand
  for scope in project global; do
    if [ "$scope" = project ]; then cfg="$d/capstone.json"
    else cfg="$GLOBAL_DIR/capstone.json"; fi
    [ -f "$cfg" ] || continue
    v=$(sed -n 's/.*"index_file"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$cfg" | head -1)
    [ -n "$v" ] || continue
    case "$v" in /*) cand="$v" ;; *) cand="$BASE/$v" ;; esac
    cand=$(abspath "$cand")
    if [ "$scope" = project ]; then
      case "$cand" in "$d"/*) printf '%s\n' "$cand"; return 0 ;; esac
    elif [ "$(dirname "$cand")" = "$d" ]; then
      printf '%s\n' "$cand"; return 0
    fi
  done
  printf '%s\n' "$d/00-index.md"
}

# sweep_non_md docs_abs disp: part 8 over every non-markdown file the
# docs area carries. The secrets column is the only one that can fire -
# these files have no frontmatter, no required headings and no Site
# cells - so the sweep runs even when the index is missing and the
# markdown pass cannot. NUL-delimited end to end (see list_non_md), and
# read through a process substitution so the loop stays in this shell
# and its findings survive.
sweep_non_md() {
  local d="$1" disp="$2" rel shown
  while IFS= read -r -d '' rel; do
    [ -n "$rel" ] || continue
    # a newline in the name would split the table row in half, so a
    # name holding a control character is shown quoted, and a literal
    # pipe - legal in a filename, fatal to a markdown cell - is
    # backslash-escaped; the path the scan opens is the raw one
    case $rel in
      *[[:cntrl:]]*) shown=$(printf '%q' "$rel") ;;
      *) shown=$rel ;;
    esac
    shown=${shown//|/\\|}
    check_part8 "$d/$rel" "$disp/$shown" "" "" "" 1
  done < <(list_non_md "$d")
}

# print_part8 : the schema section, from whatever rows part 8 collected
print_part8() {
  echo
  echo "## 8. Schema"
  echo
  if [ -n "$P8_ROWS" ]; then
    echo "| file | missing keys | missing headings | unverifiable sites | secrets |"
    echo "| --- | --- | --- | --- | --- |"
    printf '%s' "$P8_ROWS"
  else
    echo "schema: clean"
  fi
}

# run_dir docs_abs given: one report section for one docs area
run_dir() {
  local d="$1" given="$2" disp idx files f rel fm globs record dfile
  ROOT=""; IN_GIT=0; BASE="$PWD"; DOCS_ABS="$d"
  if command -v git >/dev/null 2>&1; then
    ROOT=$(git -C "$d" rev-parse --show-toplevel 2>/dev/null) && IN_GIT=1
  fi
  if [ "$IN_GIT" -eq 1 ]; then
    BASE="$ROOT"
    case "$d" in "$ROOT"/*) disp=${d#"$ROOT"/} ;; *) disp="$given" ;; esac
  else
    disp="$given"
  fi
  P1_ROWS=""; P8_ROWS=""
  echo "# map check: $disp"
  if [ -n "$PLUGIN_VERSION" ]; then echo "plugin version: $PLUGIN_VERSION"
  else echo "plugin version: unreadable; version gap not checked"; fi
  [ "$SCHEMA_OK" -eq 1 ] || echo "schema: $SCHEMA_FILE unreadable; headings and tables not checked"
  [ "$IN_GIT" -eq 1 ] || echo "not a git repo: staleness unknowable, sites unverifiable"
  idx=$(resolve_index "$d")
  if [ ! -f "$idx" ]; then
    # resolve_index only returns paths inside $d, so the shown path is
    # relative to ROOT in git and starts with the argument as given outside
    echo
    echo "no index at $disp/${idx#"$d"/}"
    FINDINGS=$((FINDINGS + 1)); IDX_FINDINGS=$((IDX_FINDINGS + 1))
    # no index means no file list, so the markdown schema pass cannot
    # run; the non-markdown sweep does not need one, and a credential
    # in a shipped file is worth naming even while the index is gone
    sweep_non_md "$d" "$disp"
    check_part7 "$d"
    print_part8
    return 0
  fi
  files=$(list_docs "$d" "$idx")
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    rel=${f#"$d"/}
    dfile="$disp/$rel"
    fm=$(frontmatter_of "$f")
    globs=$(fm_globs "$fm")
    record=$(schema_type_for "$rel")
    if [ -n "$globs" ] || [ -n "$(fm_value "$fm" capstone_version)" ]; then
      check_part1 "$dfile" "$fm" "$globs"
    fi
    check_part8 "$f" "$dfile" "$fm" "$globs" "$record" 0
  done <<< "$files"
  # the index is looked up by record rather than by path, because
  # config `index_file` may name it anything. Its record carries no
  # keys and no headings - core-authoring.md's rule that the index
  # carries no stamps - so what runs over it is the secret scan.
  check_part8 "$idx" "$disp/${idx#"$d"/}" "$(frontmatter_of "$idx")" "" index 0
  sweep_non_md "$d" "$disp"
  echo
  echo "## 1. Staleness"
  echo
  if [ -n "$P1_ROWS" ]; then
    echo "| file | stamp | capstone_version | files changed since | verdict |"
    echo "| --- | --- | --- | --- | --- |"
    printf '%s' "$P1_ROWS"
  else
    echo "no stamped files with paths_covered"
  fi
  check_part7 "$d"
  print_part8
}

main() {
  local -a dirs
  local a d abs first=1
  dirs=()
  SCHEMA_MATCHES=$(schema_pairs)
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      --headings) print_headings; exit 0 ;;
      --patterns) print_patterns; exit 0 ;;
      --schema) print_schema; exit 0 ;;
      --) shift; break ;;
      -*) die_usage "unknown flag: $1" ;;
      *) dirs+=("$1") ;;
    esac
    shift
  done
  for a in "$@"; do dirs+=("$a"); done
  [ "${#dirs[@]}" -gt 0 ] || dirs=(docs/capstone)
  for d in "${dirs[@]}"; do
    [ -d "$d" ] || die_usage "not a directory: $d"
  done
  PLUGIN_VERSION=$(plugin_version)
  FINDINGS=0; P1_FINDINGS=0; P8_FINDINGS=0; IDX_FINDINGS=0
  for d in "${dirs[@]}"; do
    abs=$(abspath "$d")
    [ "$first" -eq 1 ] || echo
    first=0
    run_dir "$abs" "${d%/}"
  done
  echo
  if [ "$IDX_FINDINGS" -gt 0 ]; then
    echo "findings: $FINDINGS (staleness $P1_FINDINGS, schema $P8_FINDINGS, missing index $IDX_FINDINGS)"
  else
    echo "findings: $FINDINGS (staleness $P1_FINDINGS, schema $P8_FINDINGS)"
  fi
  if [ "$FINDINGS" -eq 0 ]; then
    echo "MAP CHECK: current"
    exit 0
  fi
  echo "MAP CHECK: stale ($FINDINGS findings)"
  exit 1
}

main "$@"
