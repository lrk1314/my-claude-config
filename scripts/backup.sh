#!/bin/bash
# Claude Code 配置备份脚本
# 用途：将当前 Claude Code 配置备份到项目的 private 目录

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置路径
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="./private"

echo -e "${BLUE}🔄 开始备份 Claude Code 配置...${NC}"

# 检查 Claude 目录是否存在
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}⚠️  警告：Claude 配置目录不存在: $CLAUDE_DIR${NC}"
    exit 1
fi

# 创建备份目录
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/mcp-configs"
mkdir -p "$BACKUP_DIR/custom-skills"

echo -e "${GREEN}📦 备份核心配置文件...${NC}"

# 备份核心配置
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
    echo "  ✓ CLAUDE.md"
fi

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/"
    echo "  ✓ settings.json"
fi

if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
    cp "$CLAUDE_DIR/settings.local.json" "$BACKUP_DIR/"
    echo "  ✓ settings.local.json"
fi

echo -e "${GREEN}🔌 备份 MCP 配置...${NC}"

# 备份 MCP 配置
if [ -f "$CLAUDE_DIR/mcp-servers/dm8-mcp/config.json" ]; then
    cp "$CLAUDE_DIR/mcp-servers/dm8-mcp/config.json" "$BACKUP_DIR/mcp-configs/dm8-config.json"
    echo "  ✓ dm8-config.json"
fi

if [ -f "$CLAUDE_DIR/mcp-servers/mysql-mcp/config.json" ]; then
    cp "$CLAUDE_DIR/mcp-servers/mysql-mcp/config.json" "$BACKUP_DIR/mcp-configs/mysql-config.json"
    echo "  ✓ mysql-config.json"
fi

echo -e "${GREEN}🎨 备份自定义 Skills...${NC}"

# 备份自定义 skills
if [ -d "$CLAUDE_DIR/skills/dm8" ]; then
    cp -r "$CLAUDE_DIR/skills/dm8" "$BACKUP_DIR/custom-skills/"
    echo "  ✓ dm8 skill"
fi

if [ -d "$CLAUDE_DIR/skills/mysql" ]; then
    cp -r "$CLAUDE_DIR/skills/mysql" "$BACKUP_DIR/custom-skills/"
    echo "  ✓ mysql skill"
fi

if [ -d "$CLAUDE_DIR/skills/translate-skills" ]; then
    cp -r "$CLAUDE_DIR/skills/translate-skills" "$BACKUP_DIR/custom-skills/"
    echo "  ✓ translate-skills"
fi

if [ -d "$CLAUDE_DIR/skills/elicitation" ]; then
    cp -r "$CLAUDE_DIR/skills/elicitation" "$BACKUP_DIR/custom-skills/"
    echo "  ✓ elicitation"
fi

echo -e "${GREEN}✅ 备份完成！${NC}"
echo -e "${YELLOW}📝 备份位置: $BACKUP_DIR${NC}"
echo ""
echo -e "${BLUE}💡 提示：${NC}"
echo "  - private/ 目录不会被提交到 git"
echo "  - 请确保敏感信息安全"
echo "  - 可以使用 git status 查看哪些文件会被提交"
