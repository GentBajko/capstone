# Creates docs/capstone/capstone.json with all default settings if absent,
# and the docs area's .gitignore covering capstone's local-only outputs.
# The config path is fixed regardless of docs_dir (see core.md); the
# .gitignore goes in the docs area, which the first argument may relocate.
# Idempotent: never overwrites either file. Writes UTF-8 without BOM.
# Usage: powershell -ExecutionPolicy Bypass -File init-config.ps1 [docs_dir]
param([string]$DocsDir = "docs/capstone")
$Dir = Join-Path "docs" "capstone"
$File = Join-Path $Dir "capstone.json"
New-Item -ItemType Directory -Force -Path $Dir | Out-Null
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
  "pipeline": null
}
'@
  $Full = Join-Path (Get-Location).Path $File
  [System.IO.File]::WriteAllText($Full, ($Json -replace "`r`n", "`n") + "`n")
  Write-Output "created: $File"
}

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
  $IgnoreFull = Join-Path (Get-Location).Path $Ignore
  [System.IO.File]::WriteAllText($IgnoreFull, ($Rules -replace "`r`n", "`n") + "`n")
  Write-Output "created: $Ignore"
}
