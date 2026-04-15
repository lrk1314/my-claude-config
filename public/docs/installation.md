# 安装指南

## 前置要求

- Git
- Node.js 16+
- Claude Code CLI
- Codex CLI

## 推荐目录布局

```text
private/
├── claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   └── settings.local.json
├── codex/
│   ├── AGENTS.md
│   └── config.toml
├── custom-skills/
└── mcp-configs/
```

说明：

- `private/claude/` 只放 Claude Code 私有配置
- `private/codex/` 只放 Codex 私有配置
- `private/custom-skills/` 会被同时恢复到 `.claude/skills` 和 `.codex/skills`
- `private/mcp-configs/` 放数据库等 MCP 配置

兼容旧布局：

- `private/CLAUDE.md`
- `private/settings.json`
- `private/settings.local.json`

## 安装步骤

### 1. 克隆仓库

```bash
git clone https://github.com/lrk1314/my-claude-config.git
cd my-claude-config
```

### 2. 放入私有配置

至少建议准备下面这些文件：

- `private/claude/CLAUDE.md`
- `private/claude/settings.json`
- `private/claude/settings.local.json`
- `private/codex/AGENTS.md`
- `private/codex/config.toml`

如果暂时没有私有文件，恢复脚本会回退到 `public/` 下的模板文件。

### 3. 执行恢复

Windows PowerShell：

```powershell
.\scripts\restore.ps1
```

Linux/macOS：

```bash
chmod +x ./scripts/restore.sh
./scripts/restore.sh
```

### 4. 安装 MCP 依赖

如果你启用了数据库类 MCP，请在仓库根目录执行：

```bash
cd mcp-servers/mysql-mcp
npm install

cd ../dm8-mcp
npm install
```

当前脚本默认把 MCP 服务器代码同步到 Claude Code 目录。Codex 如需引用同一套服务，直接指向仓库中的 `mcp-servers/` 即可。

### 5. 验证结果

检查两个目录是否已经就位：

Windows PowerShell：

```powershell
Get-ChildItem $env:USERPROFILE\.claude
Get-ChildItem $env:USERPROFILE\.codex
```

Linux/macOS：

```bash
ls -la ~/.claude
ls -la ~/.codex
```

Claude Code 侧还可以继续检查：

```bash
claude mcp list
```

## 常见问题

### 恢复脚本执行了，但没有私人配置

先检查 `private/claude/`、`private/codex/` 是否真的有文件。没有的话，脚本会落模板而不是你的真实配置。

### Codex 为什么没有同步 `.system`

`.codex/skills/.system` 是本地系统技能，不应该进仓库，也不会通过本仓库恢复。

### 共享 skills 和私有 skills 的区别是什么

- `public/skills/`：版本化、公开、跨端共享
- `private/custom-skills/`：私有、不提交、跨端恢复

## 下一步

- 阅读 [Skills 使用指南](skills-guide.md)
- 阅读 [MCP 配置指南](mcp-guide.md)
