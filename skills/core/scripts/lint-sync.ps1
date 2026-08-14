# PowerShell twin of lint-sync.sh - asserts the same cross-file invariants.
# Run from anywhere; resolves the repo root from its own location.
$Root = Resolve-Path (Join-Path $PSScriptRoot "../../..")
Set-Location $Root
$Fail = 0
function Err($msg) { Write-Output "FAIL: $msg"; $script:Fail = 1 }

$manifests = @('.claude-plugin/plugin.json', '.claude-plugin/marketplace.json',
  '.codex-plugin/plugin.json', '.cursor-plugin/plugin.json',
  '.kimi-plugin/plugin.json', 'gemini-extension.json')

$InGit = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
  git rev-parse --is-inside-work-tree 2>$null | Out-Null
  $InGit = ($LASTEXITCODE -eq 0)
}

# 1. help.sh body == help.ps1 body
$sh = (Get-Content skills/core/scripts/help.sh) | Where-Object { $_ -notmatch "^#!/|^# |^cat <<'EOF'$|^EOF$" }
$ps = (Get-Content skills/core/scripts/help.ps1) | Where-Object { $_ -notmatch "^Write-Output @'$|^'@$|^# Prints" }
if (($sh -join "`n") -ne ($ps -join "`n")) { Err "help.sh and help.ps1 texts differ" }

# 2. exactly one version string per manifest, and one distinct value overall
$vals = @()
foreach ($f in $manifests) {
  $m = @(Select-String -Path $f -Pattern '"version": *"([^"]+)"' -AllMatches |
    ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value })
  if ($m.Count -ne 1) {
    Err "$f does not yield exactly one version string (got $($m.Count))"
    continue
  }
  $vals += $m[0]
}
$uniq = @($vals | Sort-Object -Unique)
if ($uniq.Count -gt 1) { Err "version mismatch across manifests: $($uniq -join ', ')" }

# 3/4. protocol <-> skill pairing, wrapper loadability/wiring, H1 stems
Get-ChildItem skills/core/references/protocols/*.md | ForEach-Object {
  $n = $_.BaseName
  if (-not (Test-Path "skills/$n")) { Err "protocol $n.md has no skills/$n/ wrapper" }
  $h1 = Get-Content $_.FullName -First 1
  if ($h1 -notmatch "^# $n\b") { Err "H1 of $n.md does not start '# $n' ($h1)" }
}
Get-ChildItem skills -Directory | ForEach-Object {
  $n = $_.Name
  if ($n -eq 'core') { return }
  if (-not (Test-Path "skills/$n/SKILL.md")) { Err "skill $n has no SKILL.md"; return }
  $fm = ''
  foreach ($l in (Get-Content "skills/$n/SKILL.md" | Select-Object -Skip 1 -First 9)) {
    if ($l -match '^name: *(.+?)\s*$') { $fm = $Matches[1]; break }
  }
  if ($fm -ne $n) { Err "skills/$n/SKILL.md frontmatter name is '$fm', expected '$n'" }
  if ($n -in @('help', 'core')) { return }
  if (-not (Test-Path "skills/core/references/protocols/$n.md")) { Err "skill $n has no protocol file" }
  if ((Get-Content "skills/$n/SKILL.md" -Raw) -notmatch [regex]::Escape("protocols/$n.md")) {
    Err "skills/$n/SKILL.md does not wire protocols/$n.md"
  }
}

# 3b. every protocol declares its inputs (core.md Read discipline)
Get-ChildItem skills/core/references/protocols/*.md | ForEach-Object {
  if (-not (Select-String -Path $_.FullName -Pattern '^\*\*Reads:\*\*' -Quiet)) {
    Err "$($_.Name) has no **Reads:** block"
  }
}

# 5. every skill name in help text, README table + routing, INSTALL list
$help = Get-Content skills/core/scripts/help.ps1 -Raw
$readme = Get-Content README.md -Raw
$install = Get-Content .opencode/INSTALL.md -Raw
$route = if ($readme -match '(?s)matches a capstone skill.*?invoke capstone:') { $Matches[0] } else { '' }
if (-not $route) { Err "README routing snippet not found" }
Get-ChildItem skills -Directory | ForEach-Object {
  $n = $_.Name
  if ($n -eq 'core') { return }
  if ($help -notmatch "(?m)^  $n\b") { Err "help missing command line for $n" }
  if ($readme -notmatch ([regex]::Escape("/capstone:$n") + '(?![\w-])')) { Err "README missing /capstone:$n" }
  if ($install -notmatch "(?m)(^|[ (])$n[,)]") { Err "INSTALL.md missing $n" }
  if ($route -and $route -notmatch "(?m)(^|[ (])$n[,)]") { Err "README routing snippet missing $n" }
}

# 5b. the dispatcher's reserved-word list carries every routable
#     subcommand (on Gemini, skills/core/references/dispatcher.md is the only entry point)
$skillmd = Get-Content skills/core/references/dispatcher.md -Raw
$routelist = if ($skillmd -match '(?s)The reserved subcommand words.*?each route to') { $Matches[0] } else { '' }
if (-not $routelist) { Err "dispatcher.md reserved-subcommand sentence not found" }
Get-ChildItem skills/core/references/protocols/*.md | ForEach-Object {
  $n = $_.BaseName
  $tick = [char]0x60
  if ($routelist -notmatch [regex]::Escape("$tick$n$tick")) { Err "dispatcher.md routing list missing $n" }
}

# 6. hook wiring, and the install-time global-config hook is in place
$hooks = Get-Content hooks/hooks.json -Raw
if ($hooks -notmatch '"matcher": "capstone:help"') { Err "hooks.json matcher wrong" }
if ($hooks -notmatch 'skills/core/scripts/help-hook\.sh') { Err "hooks.json does not point at help-hook.sh" }
if ((Get-Content skills/core/scripts/help-hook.sh -Raw) -notmatch '"command_name":"capstone:help"') { Err "help-hook guard wrong" }
if ((Get-Content skills/core/scripts/help-hook.sh -Raw) -notmatch 'CLAUDE_CODE_ENTRYPOINT') { Err "help-hook.sh lost its terminal-only guard (GUI surfaces swallow block reasons)" }
if ($hooks -notmatch '"SessionStart"') { Err "hooks.json has no SessionStart hook" }
if ($hooks -notmatch 'init-config\.sh --global') { Err "hooks.json SessionStart does not run init-config.sh --global" }

# 7. config template keys everywhere: the global template's keys in
#    both initializers, core.md, and README; the project-scoped keys
#    (never in the global template) documented in core.md and README
$files = @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1',
  'skills/core/references/core.md', 'README.md')
$keys = @('expertise', 'teaching_mode', 'docs_dir', 'index_file', 'subagent_threshold', 'docs_in_git', 'language')
$projKeys = @('pipeline', 'workspaces')
foreach ($f in $files) {
  $c = Get-Content $f -Raw
  foreach ($k in $keys) { if ($c -notmatch [regex]::Escape('"' + $k + '"')) { Err "$f config template missing key $k" } }
  foreach ($k in $projKeys) { if ($c -match [regex]::Escape('"' + $k + '"')) { Err "$f global template carries project-scoped key $k" } }
}
$tick = [char]0x60
foreach ($f in @('skills/core/references/core.md', 'README.md')) {
  $c = Get-Content $f -Raw
  foreach ($k in $projKeys) {
    if ($c -notmatch [regex]::Escape("$tick$k$tick")) { Err "$f does not document project-scoped config key $k" }
  }
}

# 8. .sh/.ps1 pairing (help-hook.sh exempt: hooks.json invokes bash explicitly)
Get-ChildItem skills/core/scripts/*.sh | ForEach-Object {
  $b = $_.BaseName
  if ($b -eq 'help-hook') { return }
  if (-not (Test-Path "skills/core/scripts/$b.ps1")) { Err "$b.sh has no $b.ps1 twin" }
}

# 9. every tracked .json parses (a stray comma in marketplace.json breaks
#    installation for every user, and no regex-based check would see it)
#    ConvertFrom-Json is lenient (it accepts trailing commas), so prefer
#    System.Text.Json where the runtime has it; fall back on PS 5.1.
if ($InGit) {
  $strict = [bool]('System.Text.Json.JsonDocument' -as [type])
  if (-not $strict) { Write-Output "note: System.Text.Json unavailable; JSON check is lenient on this runtime" }
  foreach ($f in (git ls-files '*.json')) {
    $raw = Get-Content $f -Raw
    try {
      if ($strict) { [void][System.Text.Json.JsonDocument]::Parse($raw) }
      else { $raw | ConvertFrom-Json -ErrorAction Stop | Out-Null }
    } catch { Err "invalid JSON: $f" }
  }
} else {
  Write-Output "note: JSON syntax check skipped (not a git checkout)"
}

# 10. no dead names anywhere tracked (lint scripts excluded: they carry
# the search literal themselves)
if ($InGit) {
  $stale = git grep -l 'archdesign' -- . ':!skills/core/scripts/lint-sync.*' 2>$null
  if ($stale) { Err "stale 'archdesign' references: $stale" }
} else {
  Write-Output "note: dead-name check skipped (not a git checkout)"
}

# 11. every writing protocol carries its changelog pointer, the exempt
#     ones say so, and the old opt-in is gone
foreach ($n in @('groom', 'plan', 'implement', 'mockup', 'logic', 'design',
    'architecture', 'code-prefs', 'stack', 'build', 'be-review', 'fe-review', 'guides',
    'onboarding', 'generate', 'sync', 'doctor')) {
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'changelog entry' -SimpleMatch -Quiet)) {
    Err "protocol $n.md has no changelog-entry step"
  }
}
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'Changelog ledger' -SimpleMatch -Quiet)) {
  Err "core.md has no Changelog ledger section"
}
if (Select-String -Path skills/core/references/protocols/implement.md -Pattern 'Offer `changelog' -SimpleMatch -Quiet) {
  Err "implement.md still carries the old opt-in changelog offer"
}
foreach ($n in @('ask')) {
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'no changelog entry|never appends a changelog' -Quiet)) {
    Err "protocol $n.md lacks its explicit changelog exemption"
  }
}

# 12. the local-only ignore list is identical in both initializers and
#     documented in core.md (hand-synced across three files)
foreach ($r in @('features/', '*-interview.md', 'capstone.json', 'review.md', 'be-review.md', 'fe-review.md', 'changelog.md')) {
  foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
    if (-not (Select-String -Path $f -Pattern "^$([regex]::Escape($r))$" -Quiet)) {
      Err "$f ignore template missing rule $r"
    }
  }
}
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'Local-only outputs' -SimpleMatch -Quiet)) {
  Err "core.md has no Local-only outputs section"
}
foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
  if (-not (Select-String -Path $f -Pattern 'docs/design' -SimpleMatch -Quiet)) {
    Err "$f dropped the legacy docs/design migration"
  }
}


# 14. the pipeline order is spelled identically everywhere it appears
$pipe = 'mockup -> logic -> design -> architecture -> code-prefs -> stack -> build'
foreach ($f in @('skills/core/scripts/help.sh', 'skills/core/scripts/help.ps1', 'skills/start/SKILL.md')) {
  if (-not (Select-String -Path $f -Pattern $pipe -SimpleMatch -Quiet)) {
    Err "$f missing the pipeline-order string"
  }
}
$pipeArrow = [char]0x2192
$pipeReadme = "mockup $pipeArrow logic $pipeArrow design $pipeArrow architecture $pipeArrow code-prefs $pipeArrow stack $pipeArrow build"
if (-not (Select-String -Path README.md -Pattern $pipeReadme -SimpleMatch -Quiet)) {
  Err "README.md missing the pipeline-order string"
}

if ($Fail -eq 0) { Write-Output "lint-sync: all invariants hold" } else { Write-Output "lint-sync: FAILURES above" }
exit $Fail
