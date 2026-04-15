# Claude Code + Codex 配置恢复脚本（Windows PowerShell）

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

function Copy-DirectoryContents {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        return
    }

    Ensure-Directory -Path $Destination
    $items = Get-ChildItem -Force -LiteralPath $Source -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        Copy-Item -LiteralPath $item.FullName -Destination $Destination -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Restore-File {
    param(
        [string[]]$Candidates,
        [string]$Fallback,
        [string]$Destination,
        [string]$Label
    )

    foreach ($candidate in $Candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            Copy-Item -LiteralPath $candidate -Destination $Destination -Force
            Write-ColorOutput "  ✓ $Label" "White"
            return
        }
    }

    if ($Fallback -and (Test-Path -LiteralPath $Fallback)) {
        Copy-Item -LiteralPath $Fallback -Destination $Destination -Force
        Write-ColorOutput "  ✓ $Label (template)" "Yellow"
        return
    }

    Write-ColorOutput "  ⚠ $Label 未找到" "Yellow"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PublicDir = Join-Path $RepoRoot "public"
$PrivateDir = Join-Path $RepoRoot "private"
$ClaudePrivateDir = Join-Path $PrivateDir "claude"
$CodexPrivateDir = Join-Path $PrivateDir "codex"
$CustomSkillsDir = Join-Path $PrivateDir "custom-skills"
$McpConfigsDir = Join-Path $PrivateDir "mcp-configs"
$RepoMcpServersDir = Join-Path $RepoRoot "mcp-servers"

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$CodexDir = Join-Path $env:USERPROFILE ".codex"

$ClaudeHooksDir = Join-Path $ClaudeDir "hooks"
$ClaudeSkillsDir = Join-Path $ClaudeDir "skills"
$ClaudeMcpDir = Join-Path $ClaudeDir "mcp-servers"
$CodexSkillsDir = Join-Path $CodexDir "skills"

Write-ColorOutput "开始恢复 Claude Code + Codex 配置..." "Blue"
Write-Host ""

Ensure-Directory -Path $ClaudeDir
Ensure-Directory -Path $ClaudeHooksDir
Ensure-Directory -Path $ClaudeSkillsDir
Ensure-Directory -Path $ClaudeMcpDir
Ensure-Directory -Path $CodexDir
Ensure-Directory -Path $CodexSkillsDir

Write-ColorOutput "恢复共享资源..." "Green"
Copy-DirectoryContents -Source (Join-Path $PublicDir "hooks") -Destination $ClaudeHooksDir
Copy-DirectoryContents -Source (Join-Path $PublicDir "skills") -Destination $ClaudeSkillsDir
Copy-DirectoryContents -Source (Join-Path $PublicDir "skills") -Destination $CodexSkillsDir
Copy-DirectoryContents -Source $CustomSkillsDir -Destination $ClaudeSkillsDir
Copy-DirectoryContents -Source $CustomSkillsDir -Destination $CodexSkillsDir

Write-ColorOutput "恢复 Claude Code 配置..." "Green"
Restore-File -Candidates @(
    (Join-Path $ClaudePrivateDir "CLAUDE.md"),
    (Join-Path $PrivateDir "CLAUDE.md")
) -Fallback (Join-Path $PublicDir "CLAUDE.女仆.template.md") -Destination (Join-Path $ClaudeDir "CLAUDE.md") -Label "CLAUDE.md"

Restore-File -Candidates @(
    (Join-Path $ClaudePrivateDir "settings.json"),
    (Join-Path $PrivateDir "settings.json")
) -Fallback (Join-Path $PublicDir "settings.template.json") -Destination (Join-Path $ClaudeDir "settings.json") -Label "settings.json"

Restore-File -Candidates @(
    (Join-Path $ClaudePrivateDir "settings.local.json"),
    (Join-Path $PrivateDir "settings.local.json")
) -Fallback (Join-Path $PublicDir "settings.local.template.json") -Destination (Join-Path $ClaudeDir "settings.local.json") -Label "settings.local.json"

Write-ColorOutput "恢复 Codex 配置..." "Green"
Restore-File -Candidates @(
    (Join-Path $CodexPrivateDir "AGENTS.md")
) -Fallback (Join-Path $PublicDir "AGENTS.女仆.template.md") -Destination (Join-Path $CodexDir "AGENTS.md") -Label "AGENTS.md"

Restore-File -Candidates @(
    (Join-Path $CodexPrivateDir "config.toml")
) -Fallback (Join-Path $PublicDir "config.template.toml") -Destination (Join-Path $CodexDir "config.toml") -Label "config.toml"

Write-ColorOutput "恢复 MCP 服务器代码..." "Green"
Copy-DirectoryContents -Source $RepoMcpServersDir -Destination $ClaudeMcpDir

$dm8Config = Join-Path $McpConfigsDir "dm8-config.json"
$mysqlConfig = Join-Path $McpConfigsDir "mysql-config.json"

if (Test-Path -LiteralPath $dm8Config) {
    Ensure-Directory -Path (Join-Path $ClaudeMcpDir "dm8-mcp")
    Copy-Item -LiteralPath $dm8Config -Destination (Join-Path $ClaudeMcpDir "dm8-mcp\config.json") -Force
    Write-ColorOutput "  ✓ dm8-config.json" "White"
}

if (Test-Path -LiteralPath $mysqlConfig) {
    Ensure-Directory -Path (Join-Path $ClaudeMcpDir "mysql-mcp")
    Copy-Item -LiteralPath $mysqlConfig -Destination (Join-Path $ClaudeMcpDir "mysql-mcp\config.json") -Force
    Write-ColorOutput "  ✓ mysql-config.json" "White"
}

Write-Host ""
Write-ColorOutput "恢复完成。" "Green"
Write-Host "Claude Code: $ClaudeDir"
Write-Host "Codex:       $CodexDir"
Write-Host ""
Write-ColorOutput "后续建议：" "Yellow"
Write-Host "  1. 如需数据库 MCP，请在 mcp-servers 目录执行 npm install"
Write-Host "  2. 检查 settings.json / config.toml 中的本地路径"
Write-Host "  3. 用 claude mcp list 验证 Claude Code 侧 MCP"
