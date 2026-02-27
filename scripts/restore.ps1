# Claude Code 配置恢复脚本（Windows PowerShell）
# 用途：将备份的配置恢复到新电脑的 Claude Code

# 颜色函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 配置路径
$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$BACKUP_DIR = ".\private"
$PUBLIC_DIR = ".\public"

Write-ColorOutput "🚀 开始恢复 Claude Code 配置..." "Blue"

# 检查备份目录
if (-not (Test-Path $BACKUP_DIR)) {
    Write-ColorOutput "❌ 错误：备份目录不存在: $BACKUP_DIR" "Red"
    Write-ColorOutput "💡 请先运行 backup.ps1 或手动创建 private\ 目录" "Yellow"
    exit 1
}

# 创建 Claude 目录（如果不存在）
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR" | Out-Null
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\hooks" | Out-Null
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\mcp-servers" | Out-Null

Write-ColorOutput "📦 复制公共配置..." "Green"

# 复制 hooks
if (Test-Path "$PUBLIC_DIR\hooks") {
    Copy-Item -Path "$PUBLIC_DIR\hooks\*" -Destination "$CLAUDE_DIR\hooks\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorOutput "  ✓ Hooks" "White"
}

# 复制公共 skills
if (Test-Path "$PUBLIC_DIR\skills") {
    Copy-Item -Path "$PUBLIC_DIR\skills\*" -Destination "$CLAUDE_DIR\skills\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorOutput "  ✓ Public Skills" "White"
}

Write-ColorOutput "🔐 复制私有配置..." "Green"

# 复制核心配置
if (Test-Path "$BACKUP_DIR\CLAUDE.md") {
    Copy-Item -Path "$BACKUP_DIR\CLAUDE.md" -Destination "$CLAUDE_DIR\" -Force
    Write-ColorOutput "  ✓ CLAUDE.md" "White"
} else {
    Write-ColorOutput "  ⚠️  CLAUDE.md 不存在，跳过" "Yellow"
}

if (Test-Path "$BACKUP_DIR\settings.json") {
    Copy-Item -Path "$BACKUP_DIR\settings.json" -Destination "$CLAUDE_DIR\" -Force
    Write-ColorOutput "  ✓ settings.json" "White"
} else {
    Write-ColorOutput "  ⚠️  settings.json 不存在，使用模板" "Yellow"
    if (Test-Path "$PUBLIC_DIR\settings.template.json") {
        Copy-Item -Path "$PUBLIC_DIR\settings.template.json" -Destination "$CLAUDE_DIR\settings.json" -Force
    }
}

if (Test-Path "$BACKUP_DIR\settings.local.json") {
    Copy-Item -Path "$BACKUP_DIR\settings.local.json" -Destination "$CLAUDE_DIR\" -Force
    Write-ColorOutput "  ✓ settings.local.json" "White"
} else {
    Write-ColorOutput "  ⚠️  settings.local.json 不存在，使用模板" "Yellow"
    if (Test-Path "$PUBLIC_DIR\settings.local.template.json") {
        Copy-Item -Path "$PUBLIC_DIR\settings.local.template.json" -Destination "$CLAUDE_DIR\settings.local.json" -Force
    }
}

Write-ColorOutput "🔌 配置 MCP 服务器..." "Green"

# 复制 MCP 服务器代码
if (Test-Path ".\mcp-servers\dm8-mcp") {
    Copy-Item -Path ".\mcp-servers\dm8-mcp" -Destination "$CLAUDE_DIR\mcp-servers\" -Recurse -Force
    Write-ColorOutput "  ✓ dm8-mcp 代码" "White"

    # 恢复配置
    if (Test-Path "$BACKUP_DIR\mcp-configs\dm8-config.json") {
        Copy-Item -Path "$BACKUP_DIR\mcp-configs\dm8-config.json" -Destination "$CLAUDE_DIR\mcp-servers\dm8-mcp\config.json" -Force
        Write-ColorOutput "  ✓ dm8-mcp 配置" "White"
    }

    # 安装依赖
    Write-ColorOutput "  📦 安装 dm8-mcp 依赖..." "Blue"
    Push-Location "$CLAUDE_DIR\mcp-servers\dm8-mcp"
    npm install --silent
    Pop-Location
}

if (Test-Path ".\mcp-servers\mysql-mcp") {
    Copy-Item -Path ".\mcp-servers\mysql-mcp" -Destination "$CLAUDE_DIR\mcp-servers\" -Recurse -Force
    Write-ColorOutput "  ✓ mysql-mcp 代码" "White"

    # 恢复配置
    if (Test-Path "$BACKUP_DIR\mcp-configs\mysql-config.json") {
        Copy-Item -Path "$BACKUP_DIR\mcp-configs\mysql-config.json" -Destination "$CLAUDE_DIR\mcp-servers\mysql-mcp\config.json" -Force
        Write-ColorOutput "  ✓ mysql-mcp 配置" "White"
    }

    # 安装依赖
    Write-ColorOutput "  📦 安装 mysql-mcp 依赖..." "Blue"
    Push-Location "$CLAUDE_DIR\mcp-servers\mysql-mcp"
    npm install --silent
    Pop-Location
}

Write-ColorOutput "🎨 恢复自定义 Skills..." "Green"

# 恢复自定义 skills
if (Test-Path "$BACKUP_DIR\custom-skills") {
    Copy-Item -Path "$BACKUP_DIR\custom-skills\*" -Destination "$CLAUDE_DIR\skills\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorOutput "  ✓ 自定义 Skills" "White"
}

Write-Host ""
Write-ColorOutput "✅ 恢复完成！" "Green"
Write-Host ""
Write-ColorOutput "📝 请检查以下配置：" "Yellow"
Write-Host "  1. API Token 是否正确 (settings.json)"
Write-Host "  2. MCP 数据库连接是否可用"
Write-Host "  3. Hooks 路径是否需要调整"
Write-Host "  4. 环境变量是否配置正确"
Write-Host ""
Write-ColorOutput "💡 提示：" "Blue"
Write-Host "  - 配置文件位置: $CLAUDE_DIR"
Write-Host "  - 可以运行 'claude mcp list' 查看 MCP 状态"
Write-Host "  - 如有问题，请查看文档: public\docs\"
