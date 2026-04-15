#!/usr/bin/env bash
# Claude Code + Codex 配置备份脚本（Linux/macOS）

set -euo pipefail
shopt -s dotglob nullglob

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLIC_SKILLS_DIR="${REPO_ROOT}/public/skills"
BACKUP_DIR="${REPO_ROOT}/private"
CLAUDE_BACKUP_DIR="${BACKUP_DIR}/claude"
CODEX_BACKUP_DIR="${BACKUP_DIR}/codex"
CUSTOM_SKILLS_DIR="${BACKUP_DIR}/custom-skills"
MCP_CONFIGS_DIR="${BACKUP_DIR}/mcp-configs"

CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${HOME}/.codex"

PUBLIC_SKILL_NAMES=()

skill_is_public() {
    local target="$1"
    local item
    for item in "${PUBLIC_SKILL_NAMES[@]}"; do
        [[ "$item" == "$target" ]] && return 0
    done
    return 1
}

copy_file_if_exists() {
    local src="$1"
    local dst="$2"
    local label="$3"

    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        echo "  ✓ ${label}"
    fi
}

sync_custom_skills_from() {
    local src_root="$1"
    local item
    local skill_name
    local dst

    [[ -d "$src_root" ]] || return 0
    mkdir -p "$CUSTOM_SKILLS_DIR"

    for item in "$src_root"/*; do
        [[ -d "$item" ]] || continue
        skill_name="$(basename "$item")"

        [[ "$skill_name" == .* ]] && continue
        if skill_is_public "$skill_name"; then
            continue
        fi

        dst="${CUSTOM_SKILLS_DIR}/${skill_name}"
        rm -rf "$dst"
        cp -R "$item" "$dst"
        echo "  ✓ 自定义 skill: ${skill_name}"
    done
}

for item in "${PUBLIC_SKILLS_DIR}"/*; do
    [[ -d "$item" ]] || continue
    PUBLIC_SKILL_NAMES+=("$(basename "$item")")
done

mkdir -p "$CLAUDE_BACKUP_DIR" "$CODEX_BACKUP_DIR" "$MCP_CONFIGS_DIR"

echo -e "${BLUE}开始备份 Claude Code + Codex 配置...${NC}"

if [[ -d "$CLAUDE_DIR" ]]; then
    echo -e "${GREEN}备份 Claude Code 配置...${NC}"
    copy_file_if_exists "${CLAUDE_DIR}/CLAUDE.md" "${CLAUDE_BACKUP_DIR}/CLAUDE.md" "CLAUDE.md"
    copy_file_if_exists "${CLAUDE_DIR}/settings.json" "${CLAUDE_BACKUP_DIR}/settings.json" "settings.json"
    copy_file_if_exists "${CLAUDE_DIR}/settings.local.json" "${CLAUDE_BACKUP_DIR}/settings.local.json" "settings.local.json"
    copy_file_if_exists "${CLAUDE_DIR}/mcp-servers/dm8-mcp/config.json" "${MCP_CONFIGS_DIR}/dm8-config.json" "dm8-config.json"
    copy_file_if_exists "${CLAUDE_DIR}/mcp-servers/mysql-mcp/config.json" "${MCP_CONFIGS_DIR}/mysql-config.json" "mysql-config.json"
    sync_custom_skills_from "${CLAUDE_DIR}/skills"
else
    echo -e "${YELLOW}未找到 Claude Code 目录：${CLAUDE_DIR}${NC}"
fi

if [[ -d "$CODEX_DIR" ]]; then
    echo -e "${GREEN}备份 Codex 配置...${NC}"
    copy_file_if_exists "${CODEX_DIR}/AGENTS.md" "${CODEX_BACKUP_DIR}/AGENTS.md" "AGENTS.md"
    copy_file_if_exists "${CODEX_DIR}/config.toml" "${CODEX_BACKUP_DIR}/config.toml" "config.toml"
    sync_custom_skills_from "${CODEX_DIR}/skills"
else
    echo -e "${YELLOW}未找到 Codex 目录：${CODEX_DIR}${NC}"
fi

echo
echo -e "${GREEN}备份完成。${NC}"
echo -e "${YELLOW}输出目录：${BACKUP_DIR}${NC}"
