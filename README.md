# My Claude Code Configuration 🚀

这是我的 Claude Code 完整配置备份和迁移工具包喵！

## 📋 项目简介

本项目提供了一套完整的 Claude Code 配置管理方案，包括：
- 全局提示词配置
- 自定义 Skills
- MCP 服务器配置
- Hooks 脚本
- 自动化备份和恢复脚本

## 🏗️ 项目结构

```
my-claude-config/
├── README.md                    # 本文件
├── .gitignore                   # Git 忽略规则
├── public/                      # 可公开部分
│   ├── CLAUDE.template.md      # 提示词模板
│   ├── hooks/                  # 钩子脚本
│   ├── skills/                 # 通用 skills
│   └── docs/                   # 文档
├── private/                     # 私有部分（不提交到 git）
│   ├── CLAUDE.md               # 个人提示词
│   ├── settings.json           # 配置文件
│   ├── settings.local.json     # 本地权限配置
│   ├── mcp-configs/            # MCP 配置
│   └── custom-skills/          # 个人定制 skills
├── mcp-servers/                 # MCP 服务器代码
│   ├── dm8-mcp/                # DM8 数据库 MCP
│   └── mysql-mcp/              # MySQL 数据库 MCP
└── scripts/                     # 自动化脚本
    ├── backup.sh               # 备份脚本
    ├── restore.sh              # 恢复脚本（Linux/Mac）
    └── restore.ps1             # 恢复脚本（Windows）
```

## 🚀 快速开始

### 1. 备份当前配置

```bash
# Linux/Mac
./scripts/backup.sh

# Windows
.\scripts\backup.ps1
```

### 2. 恢复到新电脑

```bash
# Linux/Mac
./scripts/restore.sh

# Windows PowerShell
.\scripts\restore.ps1
```

## 📦 包含的内容

### Skills
- ✅ DM8 数据库操作
- ✅ MySQL 数据库操作
- ✅ 技能翻译工具
- ✅ 心理画像分析
- ✅ 更多官方 skills...

### MCP 服务器
- ✅ DM8 MCP Server
- ✅ MySQL MCP Server

### Hooks
- ✅ 路径验证钩子（Windows）

## ⚙️ 配置说明

### 环境变量

创建 `private/.env` 文件（不会提交到 git）：

```bash
# API 配置
ANTHROPIC_AUTH_TOKEN=your_token_here
ANTHROPIC_BASE_URL=your_api_url

# 数据库配置
DM8_CONNECTION_STRING=your_db_connection
MYSQL_CONNECTION_STRING=your_mysql_connection
```

### MCP 配置

MCP 配置文件位于 `private/mcp-configs/`，包含：
- `dm8-config.json` - DM8 数据库连接配置
- `mysql-config.json` - MySQL 数据库连接配置

## 📝 使用说明

### 首次使用

1. Clone 本仓库到本地
2. 创建 `private/` 目录
3. 将你的配置文件放入 `private/` 目录
4. 运行备份脚本

### 迁移到新电脑

1. Clone 本仓库
2. 确保 `private/` 目录中有你的配置文件
3. 运行恢复脚本
4. 检查配置是否正确

## 🔒 安全说明

- ⚠️ `private/` 目录包含敏感信息，已在 `.gitignore` 中排除
- ⚠️ 不要将包含密码的配置文件提交到 git
- ⚠️ 使用环境变量管理敏感信息
- ⚠️ 建议使用私有仓库存储此项目

## 📚 文档

详细文档请查看 `public/docs/` 目录：
- [安装指南](public/docs/installation.md)
- [Skills 使用指南](public/docs/skills-guide.md)
- [MCP 配置指南](public/docs/mcp-guide.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👤 作者

- GitHub: [@lrk1314](https://github.com/lrk1314)
- Email: lirunkang1314@outlook.com

---

**注意**：本项目是个人配置备份工具，请根据自己的需求进行调整喵！
