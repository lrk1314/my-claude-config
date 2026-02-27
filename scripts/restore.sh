#!/bin/bash
# Claude Code 配置恢复脚本（Linux/Mac）
# 用途：将备份的配置恢复到新电脑的 Claude Code

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置路径
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="./private"
PUBLIC_DIR="./public"

echo -e "${BLUE}🚀 开始恢复 Claude Code 配置...${NC}"

# 检查备份目录
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ 错误：备份目录不存在: $BACKUP_DIR${NC}"
    echo -e "${YELLOW}💡 请先运行 backup.sh 或手动创建 private/ 目录${NC}"
    exit 1
fi

# 创建 Claude 目录（如果不存在）
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/mcp-servers"

echo -e "${GREEN}📦 复制公共配置...${NC}"

# 复制 hooks
if [ -d "$PUBLIC_DIR/hooks" ]; then
    cp -r "$PUBLIC_DIR/hooks/"* "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    echo "  ✓ Hooks"
fi

# 复制公共 skills
if [ -d "$PUBLIC_DIR/skills" ]; then
    cp -r "$PUBLIC_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
    echo "  ✓ Public Skills"
fi

echo -e "${GREEN}🔐 复制私有配置...${NC}"

# 复制核心配置
if [ -f "$BACKUP_DIR/CLAUDE.md" ]; then
    cp "$BACKUP_DIR/CLAUDE.md" "$CLAUDE_DIR/"
    echo "  ✓ CLAUDE.md"
else
    echo -e "${YELLOW}  ⚠️  CLAUDE.md 不存在，跳过${NC}"
fi

if [ -f "$BACKUP_DIR/settings.json" ]; then
    cp "$BACKUP_DIR/settings.json" "$CLAUDE_DIR/"
    echo "  ✓ settings.json"
else
    echo -e "${YELLOW}  ⚠️  settings.json 不存在，使用模板${NC}"
    if [ -f "$PUBLIC_DIR/settings.template.json" ]; then
        cp "$PUBLIC_DIR/settings.template.json" "$CLAUDE_DIR/settings.json"
    fi
fi

if [ -f "$BACKUP_DIR/settings.local.json" ]; then
    cp "$BACKUP_DIR/settings.local.json" "$CLAUDE_DIR/"
    echo "  ✓ settings.local.json"
else
    echo -e "${YELLOW}  ⚠️  settings.local.json 不存在，使用模板${NC}"
    if [ -f "$PUBLIC_DIR/settings.local.template.json" ]; then
        cp "$PUBLIC_DIR/settings.local.template.json" "$CLAUDE_DIR/settings.local.json"
    fi
fi

echo -e "${GREEN}🔌 配置 MCP 服务器...${NC}"

# 复制 MCP 服务器代码
if [ -d "./mcp-servers/dm8-mcp" ]; then
    cp -r "./mcp-servers/dm8-mcp" "$CLAUDE_DIR/mcp-servers/"
    echo "  ✓ dm8-mcp 代码"

    # 恢复配置
    if [ -f "$BACKUP_DIR/mcp-configs/dm8-config.json" ]; then
        cp "$BACKUP_DIR/mcp-configs/dm8-config.json" "$CLAUDE_DIR/mcp-servers/dm8-mcp/config.json"
        echo "  ✓ dm8-mcp 配置"
    fi

    # 安装依赖
    echo -e "${BLUE}  📦 安装 dm8-mcp 依赖...${NC}"
    cd "$CLAUDE_DIR/mcp-servers/dm8-mcp"
    npm install --silent
    cd - > /dev/null
fi

if [ -d "./mcp-servers/mysql-mcp" ]; then
    cp -r "./mcp-servers/mysql-mcp" "$CLAUDE_DIR/mcp-servers/"
    echo "  ✓ mysql-mcp 代码"

    # 恢复配置
    if [ -f "$BACKUP_DIR/mcp-configs/mysql-config.json" ]; then
        cp "$BACKUP_DIR/mcp-configs/mysql-config.json" "$CLAUDE_DIR/mcp-servers/mysql-mcp/config.json"
        echo "  ✓ mysql-mcp 配置"
    fi

    # 安装依赖
    echo -e "${BLUE}  📦 安装 mysql-mcp 依赖...${NC}"
    cd "$CLAUDE_DIR/mcp-servers/mysql-mcp"
    npm install --silent
    cd - > /dev/null
fi

echo -e "${GREEN}🎨 恢复自定义 Skills...${NC}"

# 恢复自定义 skills
if [ -d "$BACKUP_DIR/custom-skills" ]; then
    cp -r "$BACKUP_DIR/custom-skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
    echo "  ✓ 自定义 Skills"
fi

echo ""
echo -e "${GREEN}✅ 恢复完成！${NC}"
echo ""
echo -e "${YELLOW}📝 请检查以下配置：${NC}"
echo "  1. API Token 是否正确 (settings.json)"
echo "  2. MCP 数据库连接是否可用"
echo "  3. Hooks 路径是否需要调整"
echo "  4. 环境变量是否配置正确"
echo ""
echo -e "${BLUE}💡 提示：${NC}"
echo "  - 配置文件位置: $CLAUDE_DIR"
echo "  - 可以运行 'claude mcp list' 查看 MCP 状态"
echo "  - 如有问题，请查看文档: public/docs/"
