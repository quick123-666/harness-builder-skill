<#
.SYNOPSIS
    Inject Harness capabilities into any Git repo (Level 1-3)
.DESCRIPTION
    Create .claude/ directory with settings, mcp, agents, skills, audit, docs, scripts
.PARAMETER Path Target repo path (default current)
.PARAMETER Level Harness level: 1 / 2 / 3 (default 2)
.PARAMETER RepoName Repo name (inferred from path)
.PARAMETER Assistant Assistant name (will prompt if empty)
.PARAMETER EnableMCP Enable MCP config
.PARAMETER EnableAudit Enable audit system (Level 3 only)
.PARAMETER Force Force overwrite existing .claude directory
.EXAMPLE
    .\New-HarnessScaffold.ps1 -Path "D:\my-project" -Level 2
.EXAMPLE
    .\New-HarnessScaffold.ps1 -Level 3
.NOTES
    Author: Harness Builder
    Repo:   https://github.com/quick123-666/harness-builder-skill
    Ver:    v1.2.0
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)] [string]$Path = ".",
    [Parameter()] [ValidateSet(1,2,3)] [int]$Level = 2,
    [Parameter()] [string]$RepoName = "",
    [Parameter()] [string]$Assistant = "",
    [Parameter()] [bool]$EnableMCP = $true,
    [Parameter()] [bool]$EnableAudit = $true,
    [Parameter()] [switch]$Force
)

# Force UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# Color output helpers
# ============================================================
function Write-Step    { param([string]$M) Write-Host "`n>> $M" -ForegroundColor Cyan }
function Write-Success { param([string]$M) Write-Host "   OK $M" -ForegroundColor Green }
function Write-Warn    { param([string]$M) Write-Host "   !! $M" -ForegroundColor Yellow }
function Write-Err     { param([string]$M) Write-Host "   XX $M" -ForegroundColor Red }

# ============================================================
# UTF-8 no BOM file writer (CORE FUNCTION)
# ============================================================
function Write-Utf8File {
    param([string]$Path, [string]$Content)
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

# ============================================================
# Path processing
# ============================================================
$RootPath = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $RootPath) { Write-Err "Path not found: $Path"; exit 1 }
$RootPath = $RootPath.Path

if ([string]::IsNullOrEmpty($RepoName)) { $RepoName = Split-Path $RootPath -Leaf }

$ClaudeDir = Join-Path $RootPath ".claude"
if (Test-Path $ClaudeDir) {
    if (-not $Force) {
        Write-Err ".claude exists: $ClaudeDir. Use -Force to overwrite."
        exit 1
    } else {
        Write-Warn "Removing existing .claude (Force)"
        Remove-Item -Path $ClaudeDir -Recurse -Force
    }
}

Write-Step "Repo:    $RootPath"
Write-Step "Level:   $Level"

# ============================================================
# Assistant prefix selection (interactive)
# ============================================================
if ([string]::IsNullOrEmpty($Assistant)) {
    Write-Host "`n>> Choose assistant prefix:" -ForegroundColor Cyan
    Write-Host "   [1] claude  - Claude Code ecosystem" -ForegroundColor White
    Write-Host "   [2] openclaw - OpenClaw ecosystem" -ForegroundColor White
    Write-Host "   [3] custom  - Enter custom name" -ForegroundColor White
    Write-Host -n "   Enter choice [1-3] or type custom name: " -ForegroundColor Yellow
    $choice = Read-Host

    switch ($choice.Trim()) {
        "1" { $Assistant = "Claude Assistant" }
        "2" { $Assistant = "OpenClaw Assistant" }
        "3" {
            Write-Host -n "   Enter custom name: " -ForegroundColor Yellow
            $Assistant = Read-Host
            if ([string]::IsNullOrWhiteSpace($Assistant)) { $Assistant = "My Assistant" }
        }
        default {
            $inputTrimmed = $choice.Trim()
            if ($inputTrimmed -ne "") {
                $Assistant = $inputTrimmed
            } else {
                $Assistant = "Harness Assistant"
            }
        }
    }
}

Write-Step "Assistant: $Assistant"

# ============================================================
# Create directories
# ============================================================
Write-Step "Creating directories..."
$dirs = @(".claude", ".claude/agents", ".claude/skills")
if ($Level -ge 3 -and $EnableAudit) {
    $dirs += @("audit", "audit/logs", "audit/reports", "scripts", "docs")
}
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Path (Join-Path $RootPath $d) -Force | Out-Null
    Write-Success $d
}

# ============================================================
# settings.json
# ============================================================
Write-Step "Generating settings.json..."

$settingsLevel = switch ($Level) {
    1 { "Level 1 - Solo Harness" }
    2 { "Level 2 - Team Harness" }
    3 { "Level 3 - Organization Harness" }
}

$settings = [ordered]@{
    harness_level = $settingsLevel
    assistant     = $Assistant
    repo          = $RepoName
    permissions   = [ordered]@{
        allow = @(
            [ordered]@{ action = "Read"; scope = "$RootPath non-upload files" }
            [ordered]@{ action = "Write/Edit"; scope = "$RootPath *.md / *.json / *.html / *.css / *.txt" }
        )
        deny  = @(
            [ordered]@{
                action = "Execute command"
                scope  = @("sudo *", "rm -rf *", "rm -fr *", "git push --force *", "git reset --hard *", "del /s /q *", "npm publish *")
                reason = "Irreversible or high-risk operations"
            },
            [ordered]@{
                action = "Delete file"
                scope  = "Any file"
                reason = "Must Read and confirm with user before deletion"
            },
            [ordered]@{
                action = "Write sensitive file"
                scope  = @("*.env", "*.env.*", "*.key", "*.pem", "secrets/*")
                reason = "Never write keys or .env files"
            }
        )
    }
    sandbox = [ordered]@{
        enabled  = $true
        fsWrite  = [ordered]@{ deny = @(".env", ".env.*", "*.key", "*.pem", "secrets/") }
        network  = [ordered]@{ allowedDomains = @("*.github.com", "registry.npmjs.org", "api.anthropic.com") }
    }
    defaultMode = "default"
    hooks       = [ordered]@{
        PreToolUse = @(
            [ordered]@{ matcher = "Write/Edit *.md"; behavior = "Echo target path before write" }
            [ordered]@{ matcher = "Write/Edit *.json"; behavior = "Read existing content first, then echo path" }
            [ordered]@{ matcher = "Bash delete commands"; behavior = "Block and ask for confirmation" }
        )
        PostToolUse = @(
            [ordered]@{ matcher = "Write/Edit any file"; behavior = "Read first 50 lines after write to verify" }
        )
    }
}

if ($Level -ge 2 -and $EnableMCP) {
    $settings.permissions.allow += [ordered]@{
        action          = "MCP server call"
        scope           = @("github MCP", "other mcpServers.*")
        bypass_local_deny = $true
        reason          = "MCP uses independent channel"
    }
}

$settingsJson = $settings | ConvertTo-Json -Depth 10
Write-Utf8File -Path (Join-Path $ClaudeDir "settings.json") -Content $settingsJson
Write-Success "settings.json"

# ============================================================
# mcp.json
# ============================================================
if ($Level -ge 2 -and $EnableMCP) {
    Write-Step "Generating mcp.json..."
    $mcp = [ordered]@{
        mcpServers = [ordered]@{
            github = [ordered]@{
                command = "npx"
                args    = @("-y", "@modelcontextprotocol/server-github")
                env     = [ordered]@{
                    GITHUB_TOKEN         = '${GITHUB_TOKEN}'
                    GITHUB_DEFAULT_OWNER = '${GITHUB_DEFAULT_OWNER}'
                    GITHUB_DEFAULT_REPO  = '${GITHUB_DEFAULT_REPO}'
                }
            }
        }
    }
    Write-Utf8File -Path (Join-Path $ClaudeDir "mcp.json") -Content ($mcp | ConvertTo-Json -Depth 10)
    Write-Success "mcp.json"
}

# ============================================================
# agents/
# ============================================================
Write-Step "Generating agents..."

$architectContent = @'
---
name: architect
description: Reviews architecture decisions and suggests improvements
tools: [Read, Grep, Glob]
model: opus
maxTurns: 30
---

# Architect Agent

You are an architecture reviewer. Analyze the codebase and provide:

1. Dependency analysis
2. Coupling/cohesion assessment
3. SOLID principle compliance
4. Suggestions for improvement

## Operating Rules

- Read-only: only use Read / Grep / Glob
- Never modify files; all findings are suggestions
- Focus on high-level design, not line-by-line
- At session start, read CLAUDE.md and .claude/settings.json
'@

$testWriterContent = @'
---
name: test-writer
description: Writes unit tests and integration tests
tools: [Read, Write, Edit, Bash]
model: sonnet
maxTurns: 50
---

# Test Writer Agent

You are a test writer. Your job:

1. Identify untested code paths
2. Write unit tests (happy path + edge cases)
3. Write integration tests for public APIs
4. Ensure 80%+ coverage on new code

## Operating Rules

- Read source first, then existing tests, to learn style
- Test file naming: *.test.ts / *.spec.ts
- At session start, read CLAUDE.md and .claude/settings.json
- Do not modify source code, only write tests
'@

$reviewPrContent = @'
---
name: review-pr
description: Reviews pull requests on GitHub via MCP
tools: [Read, Bash, mcp:github]
model: sonnet
maxTurns: 20
---

# Review PR Agent

You review pull requests. When asked:

1. Use mcp:github to fetch PR diff
2. Analyze for: code quality, tests, breaking changes
3. Post review comments via mcp:github
4. Approve or request changes

## Operating Rules

- Read-only (except GitHub comment writes)
- Comments must be specific, reference line numbers
- Do not modify code in PR directly
'@

Write-Utf8File -Path (Join-Path $ClaudeDir "agents/architect.md") -Content $architectContent
Write-Success "agents/architect.md"
Write-Utf8File -Path (Join-Path $ClaudeDir "agents/test-writer.md") -Content $testWriterContent
Write-Success "agents/test-writer.md"

if ($Level -ge 2 -and $EnableMCP) {
    Write-Utf8File -Path (Join-Path $ClaudeDir "agents/review-pr.md") -Content $reviewPrContent
    Write-Success "agents/review-pr.md"
}

# ============================================================
# skills/
# ============================================================
Write-Step "Generating skills..."

$reviewPrSkillContent = @'
---
name: review-pr
description: Review a GitHub pull request with structured analysis
---

# Review PR

When the user asks to review a PR:

1. Get PR number (or fetch open PRs via GitHub MCP)
2. Fetch the diff
3. Analyze for: code quality, tests, security, breaking changes
4. Post structured review comments

## Output Format

```
## PR #N: title

### Summary
- ...

### Issues Found
- Blocking: ...
- Important: ...
- Nit: ...

### Recommendation
- Approve / Request Changes / Comment
```
'@

Write-Utf8File -Path (Join-Path $ClaudeDir "skills/review-pr.md") -Content $reviewPrSkillContent
Write-Success "skills/review-pr.md"

# ============================================================
# CLAUDE.md
# ============================================================
Write-Step "Generating CLAUDE.md..."

$claudeMd = @"
# CLAUDE.md

> Project-level spec for AI assistant: **$Assistant**

## Project

- Repo:   ``$RootPath``
- Name:   $RepoName
- Level:  $Level ($settingsLevel)
- Assistant: $Assistant

## Role and Boundaries

I ($Assistant) in this project:

- OK: read / write all non-sensitive files under ``$RootPath``
- OK: use agents defined in .claude/agents/
- OK: use skills defined in .claude/skills/
- NO: ``sudo``, ``rm -rf``, ``git push --force``, ``git reset --hard``
- NO: write ``*.env``, ``*.key``, ``*.pem``
- NO: delete any file without Read + user confirm

## Workflow (start of every session)

1. Read this file
2. Read .claude/settings.json
3. Scan workspace, confirm no unexpected changes
4. For arch/test tasks, follow constraints in .claude/agents/
5. Confirm scope with user

## Communication

- Default language: English (or Chinese per repo convention)
- Markdown formatting
- File refs: wrap path in backticks
"@

Write-Utf8File -Path (Join-Path $RootPath "CLAUDE.md") -Content $claudeMd
Write-Success "CLAUDE.md"

# ============================================================
# Level 3: Audit system
# ============================================================
if ($Level -ge 3 -and $EnableAudit) {
    Write-Step "Generating audit system (Level 3)..."

    $auditReadme = @'
# Audit Log System

> Core component of Level 3 Organization Harness.

## Directory Structure

```
audit/
  logs/      # JSONL logs (one file per day)
  reports/   # Generated reports
  README.md  # This file
```

## Log Format

One JSON object per line:

```json
{"event":"tool_use","timestamp":"2026-06-27T13:10:06Z","reason":"R01: sudo blocked","result":"denied","input":"sudo apt update","tool":"Bash"}
```

## 13 Protection Rules

| ID  | Name                  | Type | Description                          |
|-----|-----------------------|------|--------------------------------------|
| R01 | sudo block            | deny | Any sudo command                    |
| R02 | Sensitive file guard  | deny | .env / .key / .pem                  |
| R03 | Dangerous delete      | deny | rm -rf / del /s /q                  |
| R04 | Force push            | ask  | git push --force                    |
| R05 | Hard reset            | ask  | git reset --hard                    |
| R06 | npm publish           | deny | Prevent accidental publish          |
| R10 | Hook bypass           | deny | Disable/uninstall hooks             |
| R11 | Privilege escalation  | deny | sudo / RunAs                        |
| R12 | Crypto miner          | warn | Detect mining code                  |
| R13 | Data exfiltration     | warn | Detect data leakage                 |
'@

    Write-Utf8File -Path (Join-Path $RootPath "audit/README.md") -Content $auditReadme
    Write-Success "audit/README.md"

    $auditUtils = @'
# audit-utils.psm1
# Audit log utility module

function Write-AuditLog {
    param(
        [string]$Tool,
        [string]$Input,
        [string]$Result,
        [string]$Reason = ""
    )

    $entry = @{
        event     = "tool_use"
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        tool      = $Tool
        input     = $Input
        result    = $Result
        reason    = $Reason
    } | ConvertTo-Json -Compress

    $logDir = Join-Path $PSScriptRoot "..\audit\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    $date = Get-Date -Format "yyyy-MM-dd"
    $logFile = Join-Path $logDir "audit-$date.jsonl"
    Add-Content -Path $logFile -Value $entry -Encoding UTF8
}

function Get-AuditLogs {
    param([int]$Days = 7)
    $logDir = Join-Path $PSScriptRoot "..\audit\logs"
    if (-not (Test-Path $logDir)) { return @() }
    $cutoff = (Get-Date).AddDays(-$Days)
    Get-ChildItem $logDir -Filter "*.jsonl" |
        Where-Object { $_.LastWriteTime -gt $cutoff } |
        ForEach-Object { Get-Content $_.FullName }
}

function Get-AuditStats {
    param([int]$Days = 7)
    $logs = @(Get-AuditLogs -Days $Days)
    return @{
        Total   = $logs.Count
        Allowed = @($logs | Where-Object { $_ -match '"result":"allowed"' }).Count
        Denied  = @($logs | Where-Object { $_ -match '"result":"denied"' }).Count
        Asked   = @($logs | Where-Object { $_ -match '"result":"asked"' }).Count
        Warned  = @($logs | Where-Object { $_ -match '"result":"warned"' }).Count
    }
}

Export-ModuleMember -Function Write-AuditLog, Get-AuditLogs, Get-AuditStats
'@

    Write-Utf8File -Path (Join-Path $RootPath "scripts/audit-utils.psm1") -Content $auditUtils
    Write-Success "scripts/audit-utils.psm1"

    $generateReport = @'
# generate-audit-report.ps1
# Generate daily audit report from JSONL logs

Import-Module "$PSScriptRoot\audit-utils.psm1" -Force

$stats = Get-AuditStats -Days 1
$logs = Get-AuditLogs -Days 1
$date = Get-Date -Format "yyyy-MM-dd"
$report = "# Daily Audit Report - $date`n`nGenerated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n## Summary`n`n- Total:   $($stats.Total)`n- Allowed: $($stats.Allowed)`n- Denied:  $($stats.Denied)`n- Asked:   $($stats.Asked)`n- Warned:  $($stats.Warned)`n`n## Denied Operations`n"

@($logs) | Where-Object { $_ -match '"result":"denied"' } | ForEach-Object {
    try {
        $entry = $_ | ConvertFrom-Json
        $report += "`n- [$($entry.timestamp)] $($entry.tool): $($entry.input) - $($entry.reason)"
    } catch {}
}

$reportDir = "$PSScriptRoot\..\audit\reports"
if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$reportPath = Join-Path $reportDir "daily-$date.md"
$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "Report generated: $reportPath" -ForegroundColor Green
'@

    Write-Utf8File -Path (Join-Path $RootPath "scripts/generate-audit-report.ps1") -Content $generateReport
    Write-Success "scripts/generate-audit-report.ps1"
}

# ============================================================
# .gitignore
# ============================================================
$gitignorePath = Join-Path $RootPath ".gitignore"
$harnessEntries = @(
    "# Harness Builder",
    ".claude/settings.local.json",
    "audit/logs/*.jsonl",
    "audit/reports/*.md.local"
)

if (Test-Path $gitignorePath) {
    $existing = Get-Content $gitignorePath -Raw
    $toAdd = $harnessEntries | Where-Object { $existing -notmatch [regex]::Escape($_) }
    if ($toAdd) {
        Add-Content -Path $gitignorePath -Value "`n$($toAdd -join "`n")"
        Write-Success ".gitignore (appended Harness entries)"
    } else {
        Write-Success ".gitignore (already has Harness entries)"
    }
} else {
    Write-Utf8File -Path $gitignorePath -Content ($harnessEntries -join "`n")
    Write-Success ".gitignore (created)"
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Harness Level $Level injected into $RepoName" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Assistant: $Assistant" -ForegroundColor Yellow
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Yellow
Write-Host "  .claude/settings.json" -ForegroundColor White
Write-Host "  .claude/agents/       (2-3 agents)" -ForegroundColor White
Write-Host "  .claude/skills/       (1+ skill)" -ForegroundColor White
Write-Host "  CLAUDE.md" -ForegroundColor White
if ($Level -ge 2 -and $EnableMCP) { Write-Host "  .claude/mcp.json" -ForegroundColor White }
if ($Level -ge 3 -and $EnableAudit) {
    Write-Host "  audit/README.md" -ForegroundColor White
    Write-Host "  scripts/audit-utils.psm1" -ForegroundColor White
    Write-Host "  scripts/generate-audit-report.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd $RootPath" -ForegroundColor White
Write-Host "  2. git add . && git commit -m 'feat: add harness level $Level'" -ForegroundColor White
if ($Level -ge 2 -and $EnableMCP) {
    Write-Host "  3. Set GITHUB_TOKEN env var for MCP" -ForegroundColor White
}
Write-Host ""
