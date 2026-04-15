#!/usr/bin/env bash
# Claude Code + Codex 配置恢复脚本（Linux/macOS）

set -euo pipefail
shopt -s dotglob nullglob

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLIC_DIR="${REPO_ROOT}/public"
PRIVATE_DIR="${REPO_ROOT}/private"
CLAUDE_PRIVATE_DIR="${PRIVATE_DIR}/claude"
CODEX_PRIVATE_DIR="${PRIVATE_DIR}/codex"
CUSTOM_SKILLS_DIR="${PRIVATE_DIR}/custom-skills"
MCP_CONFIGS_DIR="${PRIVATE_DIR}/mcp-configs"

CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${HOME}/.codex"

copy_dir_contents() {
    local src="$1"
    local dst="$2"
    local item

    [[ -d "$src" ]] || return 0
    mkdir -p "$dst"
    for item in "$src"/*; do
        [[ -e "$item" ]] || continue
        cp -R "$item" "$dst"/
    done
}

restore_file() {
    local dst="$1"
    local fallback="$2"
    local label="$3"
    shift 3

    local candidate
    for candidate in "$@"; do
        if [[ -f "$candidate" ]]; then
            cp "$candidate" "$dst"
            echo "  ✓ ${label}"
            return 0
        fi
    done

    if [[ -f "$fallback" ]]; then
        cp "$fallback" "$dst"
        echo -e "${YELLOW}  ✓ ${label} (template)${NC}"
        return 0
    fi

    echo -e "${YELLOW}  ⚠ ${label} 未找到${NC}"
}

echo -e "${BLUE}开始恢复 Claude Code + Codex 配置...${NC}"
echo

mkdir -p "${CLAUDE_DIR}/hooks" "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/mcp-servers"
mkdir -p "${CODEX_DIR}/skills"

echo -e "${GREEN}恢复共享资源...${NC}"
copy_dir_contents "${PUBLIC_DIR}/hooks" "${CLAUDE_DIR}/hooks"
copy_dir_contents "${PUBLIC_DIR}/skills" "${CLAUDE_DIR}/skills"
copy_dir_contents "${PUBLIC_DIR}/skills" "${CODEX_DIR}/skills"
copy_dir_contents "${CUSTOM_SKILLS_DIR}" "${CLAUDE_DIR}/skills"
copy_dir_contents "${CUSTOM_SKILLS_DIR}" "${CODEX_DIR}/skills"

echo -e "${GREEN}恢复 Claude Code 配置...${NC}"
restore_file "${CLAUDE_DIR}/CLAUDE.md" "${PUBLIC_DIR}/CLAUDE.template.md" "CLAUDE.md" \
    "${CLAUDE_PRIVATE_DIR}/CLAUDE.md" \
    "${PRIVATE_DIR}/CLAUDE.md"
restore_file "${CLAUDE_DIR}/settings.json" "${PUBLIC_DIR}/settings.template.json" "settings.json" \
    "${CLAUDE_PRIVATE_DIR}/settings.json" \
    "${PRIVATE_DIR}/settings.json"
restore_file "${CLAUDE_DIR}/settings.local.json" "${PUBLIC_DIR}/settings.local.template.json" "settings.local.json" \
    "${CLAUDE_PRIVATE_DIR}/settings.local.json" \
    "${PRIVATE_DIR}/settings.local.json"

echo -e "${GREEN}恢复 Codex 配置...${NC}"
restore_file "${CODEX_DIR}/AGENTS.md" "${PUBLIC_DIR}/AGENTS.template.md" "AGENTS.md" \
    "${CODEX_PRIVATE_DIR}/AGENTS.md"
restore_file "${CODEX_DIR}/config.toml" "${PUBLIC_DIR}/config.template.toml" "config.toml" \
    "${CODEX_PRIVATE_DIR}/config.toml"

echo -e "${GREEN}恢复 MCP 服务器代码...${NC}"
copy_dir_contents "${REPO_ROOT}/mcp-servers" "${CLAUDE_DIR}/mcp-servers"

if [[ -f "${MCP_CONFIGS_DIR}/dm8-config.json" ]]; then
    mkdir -p "${CLAUDE_DIR}/mcp-servers/dm8-mcp"
    cp "${MCP_CONFIGS_DIR}/dm8-config.json" "${CLAUDE_DIR}/mcp-servers/dm8-mcp/config.json"
    echo "  ✓ dm8-config.json"
fi

if [[ -f "${MCP_CONFIGS_DIR}/mysql-config.json" ]]; then
    mkdir -p "${CLAUDE_DIR}/mcp-servers/mysql-mcp"
    cp "${MCP_CONFIGS_DIR}/mysql-config.json" "${CLAUDE_DIR}/mcp-servers/mysql-mcp/config.json"
    echo "  ✓ mysql-config.json"
fi

echo
echo -e "${GREEN}恢复完成。${NC}"
echo "Claude Code: ${CLAUDE_DIR}"
echo "Codex:       ${CODEX_DIR}"
echo
echo -e "${YELLOW}后续建议：${NC}"
echo "  1. 如需数据库 MCP，请在 mcp-servers 目录执行 npm install"
echo "  2. 检查 settings.json / config.toml 中的本地路径"
echo "  3. 用 claude mcp list 验证 Claude Code 侧 MCP"
