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
  # 10b. the removed commands must not be routable again by accident
  $help = & bash skills/core/scripts/help.sh
  $route = (Get-Content skills/core/references/dispatcher.md -Raw)
  foreach ($n in @('ask', 'changelog', 'guides', 'onboarding', 'be-review', 'fe-review')) {
    if (Test-Path "skills/$n") { Err "removed skill skills/$n/ is back" }
    if (Test-Path "skills/core/references/protocols/$n.md") { Err "removed protocol $n.md is back" }
    if ($help -match "(?m)^  $n( |`$)") { Err "help.sh advertises removed command $n" }
    if ($route -match "reserved subcommand words[\s\S]*?``$n``[\s\S]*?each route to") { Err "dispatcher.md still routes removed command $n" }
  }
  # 10c. the index lives in the docs area and carries no stamp columns
  foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1',
                   'skills/core/references/core.md', 'README.md')) {
    if (-not (Select-String -Path $f -Pattern '"index_file": "docs/capstone/00-index.md"' -SimpleMatch -Quiet)) {
      Err "$f does not carry the docs-area index_file default"
    }
  }
  if (Select-String -Path skills/core/references/protocols/generate.md -Pattern 'Topic | File | Commit' -SimpleMatch -Quiet) {
    Err "generate.md still specifies stamp columns in the index table"
  }
  foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
    if (-not (Select-String -Path $f -Pattern '00-index.md' -SimpleMatch -Quiet)) {
      Err "$f lost the root-DESIGN.md index migration"
    }
    if (-not (Select-String -Path $f -Pattern 'uiux-interview.md' -SimpleMatch -Quiet)) {
      Err "$f lost the design->uiux migration"
    }
  }
} else {
  Write-Output "note: dead-name check skipped (not a git checkout)"
}

# 11. every writing protocol carries its changelog pointer, the exempt
#     ones say so, and the old opt-in is gone
foreach ($n in @('groom', 'plan', 'implement', 'mockup', 'logic', 'uiux',
    'architecture', 'code-prefs', 'stack', 'build', 'review',
    'generate', 'sync', 'doctor')) {
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'changelog entry' -SimpleMatch -Quiet)) {
    Err "protocol $n.md has no changelog-entry step"
  }
}
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'Changelog ledger' -SimpleMatch -Quiet)) {
  Err "core.md has no Changelog ledger section"
}

# 3c. the shared rules are split across core.md and core-authoring.md
foreach ($d in Get-ChildItem skills -Directory) {
  $n = $d.Name
  if ($n -in @('core', 'help')) { continue }
  $s = "skills/$n/SKILL.md"
  if (-not (Test-Path $s)) { continue }
  if (-not (Select-String -Path $s -Pattern 'references/core\.md' -Quiet)) {
    Err "skills/$n/SKILL.md does not wire core.md"
  }
  if ($n -in @('start', 'feature')) {
    if (-not (Select-String -Path $s -Pattern 'core-authoring\.md` is not' -Quiet)) {
      Err "router $n should read core.md alone and say why"
    }
  } elseif (-not (Select-String -Path $s -Pattern 'and `\.\./core/references/core-authoring\.md`' -Quiet)) {
    Err "skills/$n/SKILL.md does not wire core-authoring.md"
  }
}
if (-not (Test-Path skills/core/references/core-authoring.md)) { Err "core-authoring.md is missing" }
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'core-authoring.md' -SimpleMatch -Quiet)) {
  Err "core.md does not point at core-authoring.md"
}
if (-not (Select-String -Path skills/core/references/dispatcher.md -Pattern 'core-authoring.md' -SimpleMatch -Quiet)) {
  Err "dispatcher.md does not load core-authoring.md"
}
if (Select-String -Path skills/core/references/core.md -Pattern '^Maintenance: each subcommand' -Quiet) {
  Err "core.md still carries the contributor Maintenance block (belongs in CONTRIBUTING.md)"
}
if (-not (Test-Path CONTRIBUTING.md)) { Err "CONTRIBUTING.md is missing" }
foreach ($h in @('Changelog ledger', 'Interview lifecycle', 'Hard rules', 'Read discipline')) {
  if (-not (Select-String -Path skills/core/references/core.md -Pattern "^## .*$h" -Quiet)) { Err "core.md lost section: $h" }
  if (Select-String -Path skills/core/references/core-authoring.md -Pattern "^## .*$h" -Quiet) { Err "core-authoring.md duplicates core.md section: $h" }
}
foreach ($h in @('Local-only outputs', 'Artifact seeding', 'Index maintenance')) {
  if (-not (Select-String -Path skills/core/references/core-authoring.md -Pattern "^## .*$h" -Quiet)) { Err "core-authoring.md lost section: $h" }
  if (Select-String -Path skills/core/references/core.md -Pattern "^## .*$h" -Quiet) { Err "core.md duplicates core-authoring.md section: $h" }
}

# 3d. the git standards code-craft.md defines are wired where code lands
foreach ($n in @('plan', 'build', 'implement')) {
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'code-craft' -SimpleMatch -Quiet)) {
    Err "protocol $n.md does not reference code-craft.md"
  }
}
if (-not (Select-String -Path skills/core/references/code-craft.md -Pattern '^## Git: branches, commits' -Quiet)) {
  Err "code-craft.md has no Git section"
}
if (-not (Select-String -Path skills/core/references/protocols/implement.md -Pattern 'Git section' -SimpleMatch -Quiet)) {
  Err "implement.md does not cite code-craft's Git section"
}
if (Select-String -Path skills/core/references/protocols/implement.md -Pattern 'Offer `changelog' -SimpleMatch -Quiet) {
  Err "implement.md still carries the old opt-in changelog offer"
}
# the ledger outlived the `changelog` command: changelog.md is still
# written by every stage, but nothing may route to a protocol for it
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'Merges:' -SimpleMatch -Quiet)) {
  Err "core.md lost the changelog merge-resolution rule"
}

# 12. the local-only ignore list is identical in both initializers and
#     documented in core.md (hand-synced across three files); changelog.md
#     is part of the reference and must never reappear in the templates,
#     and both initializers must carry the unignore migration for it
foreach ($r in @('features/', '*-interview.md', 'capstone.json', 'review.md', 'be-review.md', 'fe-review.md')) {
  foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
    if (-not (Select-String -Path $f -Pattern "^$([regex]::Escape($r))$" -Quiet)) {
      Err "$f ignore template missing rule $r"
    }
  }
}
foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
  if (Select-String -Path $f -Pattern '^changelog\.md$' -Quiet) {
    Err "$f ignore template still lists changelog.md (it follows docs_in_git now)"
  }
  if (-not (Select-String -Path $f -Pattern 'unignored: changelog.md' -SimpleMatch -Quiet)) {
    Err "$f lost the changelog.md unignore migration"
  }
}
if (-not (Select-String -Path skills/core/references/core-authoring.md -Pattern 'Local-only outputs' -SimpleMatch -Quiet)) {
  Err "core-authoring.md has no Local-only outputs section"
}
foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
  if (-not (Select-String -Path $f -Pattern 'docs/design' -SimpleMatch -Quiet)) {
    Err "$f dropped the legacy docs/design migration"
  }
}


# 14. the pipeline order is spelled identically everywhere it appears
$pipe = 'mockup -> logic -> uiux -> architecture -> code-prefs -> stack -> build'
foreach ($f in @('skills/core/scripts/help.sh', 'skills/core/scripts/help.ps1', 'skills/start/SKILL.md')) {
  if (-not (Select-String -Path $f -Pattern $pipe -SimpleMatch -Quiet)) {
    Err "$f missing the pipeline-order string"
  }
}
$pipeArrow = [char]0x2192
$pipeReadme = "mockup $pipeArrow logic $pipeArrow uiux $pipeArrow architecture $pipeArrow code-prefs $pipeArrow stack $pipeArrow build"
if (-not (Select-String -Path README.md -Pattern $pipeReadme -SimpleMatch -Quiet)) {
  Err "README.md missing the pipeline-order string"
}

# 12c. execution is capstone's own: the two code-writing stages ask the
#      user for subagent-vs-inline, and no protocol invokes superpowers
foreach ($n in @('implement', 'build')) {
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'execution: subagent | inline' -SimpleMatch -Quiet)) {
    Err "protocol $n.md does not record the execution mode"
  }
  if (-not (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'Ask the mode once' -SimpleMatch -Quiet)) {
    Err "protocol $n.md does not ask subagent-vs-inline before executing"
  }
}
$sp = Get-ChildItem skills/core/references/protocols -Filter *.md |
  Where-Object { Select-String -Path $_.FullName -Pattern 'superpowers:' -SimpleMatch -Quiet }
if ($sp) { Err "a protocol invokes a superpowers skill: $($sp.Name -join ' ')" }
if (Select-String -Path skills/core/references/core-authoring.md -Pattern 'superpowers' -SimpleMatch -Quiet) {
  Err "core-authoring.md still lists superpowers as an installable delegation"
}

# 12d. review is one command with two sides, one output file, ignored
foreach ($pat in @('docs/capstone/review.md', 'rewrites only its own section')) {
  if (-not (Select-String -Path skills/core/references/protocols/review.md -Pattern $pat -SimpleMatch -Quiet)) {
    Err "review.md missing: $pat"
  }
}
foreach ($f in @('skills/core/scripts/init-config.sh', 'skills/core/scripts/init-config.ps1')) {
  if (-not (Select-String -Path $f -Pattern '^review\.md$' -Quiet)) {
    Err "$f ignore template does not cover review.md"
  }
}
if (-not (Select-String -Path skills/core/references/core.md -Pattern 'sole opinionated output' -SimpleMatch -Quiet)) {
  Err "core.md does not name review as the sole opinionated output"
}

# 12e. the craft files are the method, not a fallback
foreach ($n in @('uiux', 'review', 'build')) {
  if (Select-String -Path "skills/core/references/protocols/$n.md" -Pattern 'impeccable|design-taste|improve-codebase-architecture|codebase-design' -Quiet) {
    Err "protocol $n.md still routes method to an installed skill"
  }
}
if (Select-String -Path skills/core/references/core-authoring.md -Pattern 'Delegation installs' -SimpleMatch -Quiet) {
  Err "core-authoring.md still carries the Delegation installs section"
}
foreach ($f in @('uiux-craft', 'arch-craft')) {
  foreach ($pat in @('**Attribution.**', 'This file is the method')) {
    if (-not (Select-String -Path "skills/core/references/$f.md" -Pattern $pat -SimpleMatch -Quiet)) {
      Err "$f.md missing: $pat"
    }
  }
}
foreach ($pair in @(@('uiux-craft', 'Apache License 2.0'),
                    @('uiux-craft', 'Copyright (c) 2026 Leonxlnx'),
                    @('arch-craft', 'Matt Pocock'))) {
  if (-not (Select-String -Path "skills/core/references/$($pair[0]).md" -Pattern $pair[1] -SimpleMatch -Quiet)) {
    Err "$($pair[0]).md missing licence line: $($pair[1])"
  }
}

# 12f. uiux/ gets the same generate+sync extraction logic/ has
foreach ($pair in @(
    @('generate.md', '**Design extraction**'),
    @('sync.md', '**Design coverage.**'),
    @('uiux.md', 'Invoked by `generate` or `sync`'),
    @('logic.md', 'Invoked by `generate` or `sync`'),
    @('sync.md', 'never touched here'))) {
  if (-not (Select-String -Path "skills/core/references/protocols/$($pair[0])" -Pattern $pair[1] -SimpleMatch -Quiet)) {
    Err "$($pair[0]) missing: $($pair[1])"
  }
}

if ($Fail -eq 0) { Write-Output "lint-sync: all invariants hold" } else { Write-Output "lint-sync: FAILURES above" }
exit $Fail
