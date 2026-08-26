# Materializes capstone's files, idempotently:
#   0. creates the global config <global>/capstone.json if absent
#      (-Global: do only this, the SessionStart hook's mode, silent
#       unless it creates)
#   1. migrates a legacy docs/design tree to docs/capstone
#   2. creates <docs_dir>/.gitignore if absent; drops the stale
#      changelog.md rule from an existing one
# The global folder is ~/.claude, or $env:CLAUDE_CONFIG_DIR when the
# agent sets it ($env:CAPSTONE_GLOBAL_DIR overrides both, for
# non-Claude agents). The per-project docs/capstone/capstone.json is
# never created here: it is optional override/state, written by
# protocols only when a project-scoped key gets recorded (see core.md).
# The .gitignore goes in the docs area, which the DocsDir argument may
# relocate. Never overwrites an existing config; only the stale-rule
# removal above touches an existing ignore file. UTF-8 without BOM.
# Usage: powershell -ExecutionPolicy Bypass -File init-config.ps1 [-Global] [docs_dir]
param([switch]$Global, [string]$DocsDir = "docs/capstone")
$Legacy = Join-Path "docs" "design"
$Target = Join-Path "docs" "capstone"

function Write-Utf8NoBom($Path, $Text) {
  # Get-ChildItem hands back absolute paths; Join-Path would double them.
  $Full = if ([System.IO.Path]::IsPathRooted($Path)) { $Path }
          else { Join-Path (Get-Location).Path $Path }
  [System.IO.File]::WriteAllText($Full, ($Text -replace "`r`n", "`n"))
}
function Repoint($Path) {
  if (Test-Path $Path) {
    Write-Utf8NoBom $Path ((Get-Content $Path -Raw) -replace 'docs/design', 'docs/capstone')
  }
}

# 0. the global config
$GlobalDir = if ($env:CAPSTONE_GLOBAL_DIR) { $env:CAPSTONE_GLOBAL_DIR }
             elseif ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR }
             else { Join-Path $HOME ".claude" }
$GlobalFile = Join-Path $GlobalDir "capstone.json"
if (-not (Test-Path $GlobalFile)) {
  New-Item -ItemType Directory -Force -Path $GlobalDir | Out-Null
  $GlobalJson = @'
{
  "expertise": null,
  "teaching_mode": false,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en"
}
'@
  Write-Utf8NoBom $GlobalFile ($GlobalJson + "`n")
  Write-Output "created: $GlobalFile"
}
if ($Global) { exit 0 }

# 1. Retroactive migration. Only when the new tree does not exist yet;
#    if both are present this is not a stale layout and nothing is merged.
if ((Test-Path $Legacy) -and -not (Test-Path $Target)) {
  $tracked = $false
  if (Get-Command git -ErrorAction SilentlyContinue) {
    $ls = git ls-files $Legacy 2>$null
    $tracked = [bool]$ls
  }
  $moved = $false
  if ($tracked) {
    git mv $Legacy $Target 2>$null
    $moved = ($LASTEXITCODE -eq 0)
  }
  if (-not $moved) { Move-Item -Path $Legacy -Destination $Target }
  Write-Output "migrated: $Legacy -> $Target"

  # Repoint the paths the move invalidated: the generated docs' own
  # cross-references, the root index, and docs_dir if it named the old
  # default (a custom docs_dir is left alone).
  Get-ChildItem -Path $Target -Recurse -File -Filter *.md |
    ForEach-Object { Repoint $_.FullName }
  $Idx = "DESIGN.md"
  $Cfg = Join-Path $Target "capstone.json"
  if (Test-Path $Cfg) {
    if ((Get-Content $Cfg -Raw) -match '"index_file"\s*:\s*"([^"]+)"') { $Idx = $Matches[1] }
    Repoint $Cfg
  }
  Repoint $Idx
  Write-Output "repointed: $Target/**/*.md, $Idx, docs_dir"
  if ($DocsDir -eq 'docs/design') { $DocsDir = 'docs/capstone' }
} elseif ((Test-Path $Legacy) -and (Test-Path $Target)) {
  Write-Output "note: both $Legacy and $Target exist - not merging; $Target wins"
}

# 2. the docs area's ignore list
New-Item -ItemType Directory -Force -Path $DocsDir | Out-Null
$Ignore = Join-Path $DocsDir ".gitignore"
if (Test-Path $Ignore) {
  # Older versions ignored changelog.md. It is part of the reference
  # now (follows docs_in_git), so drop the stale rule.
  $lines = @(Get-Content $Ignore)
  if ($lines -contains 'changelog.md') {
    $kept = @($lines | Where-Object { $_ -ne 'changelog.md' })
    Write-Utf8NoBom $Ignore (($kept -join "`n") + "`n")
    Write-Output "unignored: changelog.md in $Ignore"
  } else {
    Write-Output "exists: $Ignore"
  }
} else {
  $Rules = @'
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
'@
  Write-Utf8NoBom $Ignore ($Rules + "`n")
  Write-Output "created: $Ignore"
}

# 3. Retroactive untracking. A repo that committed these before the
#    ignore list existed keeps tracking them - .gitignore only affects
#    untracked paths. Drop them from the index; every file stays on disk.
if (Get-Command git -ErrorAction SilentlyContinue) {
  git rev-parse --is-inside-work-tree 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    foreach ($d in @($DocsDir, $Target) | Select-Object -Unique) {
      if (-not (Test-Path $d)) { continue }
      $stale = @(git ls-files -i -c --exclude-standard -- $d 2>$null)
      if ($stale.Count -gt 0) {
        # -f: a migrated file can have staged content differing from both
        # the worktree and HEAD, which plain rm --cached refuses.
        # --cached keeps the working file either way.
        git rm --cached --force --quiet -- $stale
        Write-Output "untracked $($stale.Count) file(s) under $d now covered by .gitignore (kept on disk)"
      }
    }
  }
}

# A skipped git branch above leaves $LASTEXITCODE non-zero (e.g. 128 from
# rev-parse outside a repo); callers and CI read the script exit code, so
# reaching this line means success.
exit 0
