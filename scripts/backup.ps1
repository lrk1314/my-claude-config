# Claude Code + Codex 配置备份脚本（Windows PowerShell）

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Ensure-Directory {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Copy-FileIfExists {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (Test-Path -LiteralPath $Source) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-ColorOutput "  ✓ $Label" "White"
    }
}

function Sync-CustomSkills {
    param(
        [string]$SourceRoot,
        [string[]]$PublicSkillNames,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        return
    }

    Ensure-Directory -Path $DestinationRoot
    $skillDirs = Get-ChildItem -Directory -LiteralPath $SourceRoot -ErrorAction SilentlyContinue

    foreach ($skillDir in $skillDirs) {
        if ($skillDir.Name.StartsWith(".")) {
            continue
        }

        if ($PublicSkillNames -contains $skillDir.Name) {
            continue
        }

        $target = Join-Path $DestinationRoot $skillDir.Name
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }

        Copy-Item -LiteralPath $skillDir.FullName -Destination $target -Recurse -Force
        Write-ColorOutput "  ✓ 自定义 skill: $($skillDir.Name)" "White"
    }
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PublicSkillsDir = Join-Path $RepoRoot "public\skills"
$BackupDir = Join-Path $RepoRoot "private"
$ClaudeBackupDir = Join-Path $BackupDir "claude"
$CodexBackupDir = Join-Path $BackupDir "codex"
$CustomSkillsDir = Join-Path $BackupDir "custom-skills"
$McpConfigsDir = Join-Path $BackupDir "mcp-configs"

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$CodexDir = Join-Path $env:USERPROFILE ".codex"

Ensure-Directory -Path $ClaudeBackupDir
Ensure-Directory -Path $CodexBackupDir
Ensure-Directory -Path $McpConfigsDir

$publicSkillNames = @()
if (Test-Path -LiteralPath $PublicSkillsDir) {
    $publicSkillNames = Get-ChildItem -Directory -LiteralPath $PublicSkillsDir | Select-Object -ExpandProperty Name
}

Write-ColorOutput "开始备份 Claude Code + Codex 配置..." "Blue"

if (Test-Path -LiteralPath $ClaudeDir) {
    Write-ColorOutput "备份 Claude Code 配置..." "Green"
    Copy-FileIfExists -Source (Join-Path $ClaudeDir "CLAUDE.md") -Destination (Join-Path $ClaudeBackupDir "CLAUDE.md") -Label "CLAUDE.md"
    Copy-FileIfExists -Source (Join-Path $ClaudeDir "settings.json") -Destination (Join-Path $ClaudeBackupDir "settings.json") -Label "settings.json"
    Copy-FileIfExists -Source (Join-Path $ClaudeDir "settings.local.json") -Destination (Join-Path $ClaudeBackupDir "settings.local.json") -Label "settings.local.json"
    Copy-FileIfExists -Source (Join-Path $ClaudeDir "mcp-servers\dm8-mcp\config.json") -Destination (Join-Path $McpConfigsDir "dm8-config.json") -Label "dm8-config.json"
    Copy-FileIfExists -Source (Join-Path $ClaudeDir "mcp-servers\mysql-mcp\config.json") -Destination (Join-Path $McpConfigsDir "mysql-config.json") -Label "mysql-config.json"
    Sync-CustomSkills -SourceRoot (Join-Path $ClaudeDir "skills") -PublicSkillNames $publicSkillNames -DestinationRoot $CustomSkillsDir
}
else {
    Write-ColorOutput "未找到 Claude Code 目录：$ClaudeDir" "Yellow"
}

if (Test-Path -LiteralPath $CodexDir) {
    Write-ColorOutput "备份 Codex 配置..." "Green"
    Copy-FileIfExists -Source (Join-Path $CodexDir "AGENTS.md") -Destination (Join-Path $CodexBackupDir "AGENTS.md") -Label "AGENTS.md"
    Copy-FileIfExists -Source (Join-Path $CodexDir "config.toml") -Destination (Join-Path $CodexBackupDir "config.toml") -Label "config.toml"
    Sync-CustomSkills -SourceRoot (Join-Path $CodexDir "skills") -PublicSkillNames $publicSkillNames -DestinationRoot $CustomSkillsDir
}
else {
    Write-ColorOutput "未找到 Codex 目录：$CodexDir" "Yellow"
}

Write-Host ""
Write-ColorOutput "备份完成。" "Green"
Write-Host "输出目录: $BackupDir"
