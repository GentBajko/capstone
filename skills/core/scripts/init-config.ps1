# Materializes capstone's local files, idempotently:
#   0. migrates a legacy docs/design tree to docs/capstone
#   1. creates docs/capstone/capstone.json if absent
#   2. creates <docs_dir>/.gitignore if absent
# The config path is fixed regardless of docs_dir (see core.md); the
# .gitignore goes in the docs area, which the first argument may relocate.
# Never overwrites an existing config or ignore file. UTF-8 without BOM.
# Usage: powershell -ExecutionPolicy Bypass -File init-config.ps1 [docs_dir]
param([string]$DocsDir = "docs/capstone")
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

# 0. Retroactive migration. Only when the new tree does not exist yet —
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

# 1. config, at the fixed path
$File = Join-Path $Target "capstone.json"
New-Item -ItemType Directory -Force -Path $Target | Out-Null
if (Test-Path $File) {
  Write-Output "exists: $File"
} else {
  $Json = @'
{
  "expertise": null,
  "docs_dir": "docs/capstone",
  "index_file": "DESIGN.md",
  "subagent_threshold": 150,
  "docs_in_git": "ask",
  "language": "en",
  "pipeline": null,
  "workspaces": null
}
'@
  Write-Utf8NoBom $File ($Json + "`n")
  Write-Output "created: $File"
}

# 2. the docs area's ignore list
New-Item -ItemType Directory -Force -Path $DocsDir | Out-Null
$Ignore = Join-Path $DocsDir ".gitignore"
if (Test-Path $Ignore) {
  Write-Output "exists: $Ignore"
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
changelog.md
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
