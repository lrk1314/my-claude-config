# My Claude Code Configuration

这个仓库现在用于统一管理 Claude Code 和 Codex 的迁移资产。仓库名沿用旧名字，但内容已经改成“双端共享 skills，端侧各自落配置”的结构。

## 现在管理什么

- `public/skills/`：Claude Code 和 Codex 共用的公开 skills
- `public/CLAUDE.女仆.template.md`、`public/CLAUDE.猫娘.template.md`、`public/settings*.template.json`：Claude Code 模板
- `public/AGENTS.女仆.template.md`、`public/AGENTS.猫娘.template.md`、`public/config.template.toml`：Codex 模板
- `public/hooks/`：Claude Code 可复用 hooks
- `mcp-servers/`：版本化管理的 MCP 服务器代码
- `private/`：不进 Git 的个人配置、权限和私有技能

## 目录结构

```text
my-claude-config/
├── README.md
├── .gitignore
├── .env.example
├── public/
│   ├── CLAUDE.女仆.template.md
│   ├── CLAUDE.猫娘.template.md
│   ├── AGENTS.女仆.template.md
│   ├── AGENTS.猫娘.template.md
│   ├── settings.template.json
│   ├── settings.local.template.json
│   ├── config.template.toml
│   ├── hooks/
│   ├── skills/
│   └── docs/
├── private/                      # git ignore
│   ├── claude/
│   │   ├── CLAUDE.md
│   │   ├── settings.json
│   │   └── settings.local.json
│   ├── codex/
│   │   ├── AGENTS.md
│   │   └── config.toml
│   ├── custom-skills/
│   └── mcp-configs/
├── mcp-servers/
│   ├── dm8-mcp/
│   └── mysql-mcp/
└── scripts/
    ├── backup.sh
    ├── backup.ps1
    ├── restore.sh
    └── restore.ps1
```

## 这次调整的重点

- `public/skills/` 现在被视为共享 skill 仓库，不再区分 Claude 版和 Codex 版
- 默认提示词模板切换为 `public/AGENTS.女仆.template.md` 和 `public/CLAUDE.女仆.template.md`
- 原有提示词模板已重命名为 `*.猫娘.template.md`，文件内容保持不变
- 恢复脚本会把共享 skills 同时同步到 `~/.claude/skills` 和 `~/.codex/skills`
- `C:\Users\lirun\.codex\skills\.system` 这类系统技能不纳入仓库，只保留你自己的共享技能
- 新增同步入库的 skills：
  - `miniprogram-architect`
  - `work-daily-report`
  - `uhf-b-service-packaging`

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/lrk1314/my-claude-config.git
cd my-claude-config
```

### 2. 准备私有配置

按下面的布局放自己的配置文件：

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

如果你还没整理私有目录，也兼容旧布局 `private/CLAUDE.md`、`private/settings.json`、`private/settings.local.json`。

### 3. 恢复到本机

Windows PowerShell：

```powershell
.\scripts\restore.ps1
```

Linux/macOS：

```bash
chmod +x ./scripts/restore.sh
./scripts/restore.sh
```

恢复脚本会做这些事：

- Claude Code：恢复 `CLAUDE.md`、`settings.json`、`settings.local.json`、`hooks`、共享 skills、MCP 服务器代码
- Codex：恢复 `AGENTS.md`、`config.toml`、共享 skills
- 两端都会额外合并 `private/custom-skills/`

### 4. 备份当前机器配置

Windows PowerShell：

```powershell
.\scripts\backup.ps1
```

Linux/macOS：

```bash
./scripts/backup.sh
```

## Skills 概览

当前仓库包含 33 个共享 skills，覆盖以下几类：

- Makepad / 图形 / 前端
- 文档处理：`docx`、`pdf`、`pptx`、`xlsx`
- 数据库：`dm8`、`mysql`
- 自动化与测试：`playwright-cli`、`webapp-testing`
- 协作与流程：`doc-coauthoring`、`internal-comms`、`work-daily-report`
- 架构与项目技能：`miniprogram-architect`、`uhf-b-service-packaging`

完整列表见 [public/skills/README.md](public/skills/README.md)。

## MCP 管理策略

- 仓库里只版本化 `mcp-servers/` 代码和模板
- 私有连接信息放在 `private/mcp-configs/`
- 当前恢复脚本默认把 MCP 服务器安装到 Claude Code 目录
- Codex 侧如果要接同一套 MCP 服务，按你的本地配置方式手动引用仓库中的 `mcp-servers/` 即可

## 注意事项

- 不要把真实 token、数据库密码、`auth.json`、`config.toml` 等私密文件直接提交到仓库
- `public/skills/` 只放可共享、可版本化的技能
- `private/custom-skills/` 适合放不想公开、但要在两端一起恢复的技能
- Codex 的系统目录 `.codex/skills/.system` 故意不进仓库

## 相关文档

- [安装指南](public/docs/installation.md)
- [Skills 使用指南](public/docs/skills-guide.md)
- [MCP 配置指南](public/docs/mcp-guide.md)
