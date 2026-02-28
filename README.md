# My Claude Code Configuration 🚀

这是我的 Claude Code 完整配置备份和迁移工具包喵！包含全局提示词、30+ Skills、MCP 服务器、Hooks 脚本等喵！

## 📋 项目简介

本项目提供了一套完整的 Claude Code 配置管理方案，帮助你：
- ✅ 快速配置 Claude Code 为专业级 AI 编程助手
- ✅ 跨设备同步配置
- ✅ 使用预制的 30+ Skills
- ✅ 集成数据库 MCP 服务器
- ✅ 管理敏感信息（不提交到 Git）

## 🏗️ 项目结构

```
my-claude-config/
├── README.md                    # 本文件
├── .gitignore                   # Git 忽略规则
├── .env.example                 # 环境变量示例
├── public/                      # 可公开部分（已提交到 Git）
│   ├── CLAUDE.template.md      # 全局提示词模板 ⭐️
│   ├── settings.template.json   # Claude Code 设置模板
│   ├── settings.local.template.json  # 本地权限设置模板
│   ├── hooks/                  # 自定义钩子脚本
│   ├── skills/                 # 30+ 预制 Skills ⭐️
│   │   ├── 00-getting-started/ # Makepad 入门
│   │   ├── 01-core/            # Makepad 核心概念
│   │   ├── 02-components/      # Makepad 组件库
│   │   ├── 03-graphics/        # Makepad 图形和动画
│   │   ├── 04-patterns/        # Makepad 设计模式
│   │   ├── 05-deployment/      # Makepad 部署
│   │   ├── 06-reference/       # Makepad 参考文档
│   │   ├── 99-evolution/       # 自进化 Skill 系统
│   │   ├── algorithmic-art/    # 算法艺术生成
│   │   ├── brand-guidelines/   # Anthropic 品牌规范
│   │   ├── canvas-design/      # Canvas 设计工具
│   │   ├── dm8/                # DM8 数据库操作
│   │   ├── doc-coauthoring/    # 文档协作
│   │   ├── docx/               # Word 文档处理
│   │   ├── elicitation/        # 心理画像分析
│   │   ├── frontend-design/    # 前端设计
│   │   ├── internal-comms/     # 内部沟通模板
│   │   ├── mcp-builder/        # MCP 服务器构建
│   │   ├── mysql/              # MySQL 数据库操作
│   │   ├── pdf/                # PDF 文档处理
│   │   ├── playwright-cli/     # Playwright 自动化
│   │   ├── pptx/               # PowerPoint 处理
│   │   ├── skill-creator/      # Skill 创建工具
│   │   ├── slack-gif-creator/  # Slack GIF 生成
│   │   ├── theme-factory/      # 主题工厂
│   │   ├── translate-skills/   # Skill 翻译工具
│   │   ├── web-artifacts-builder/  # Web Artifact 构建
│   │   ├── web-fetch/          # Web 内容获取
│   │   ├── webapp-testing/     # Web 应用测试
│   │   └── xlsx/               # Excel 处理
│   └── docs/                   # 使用文档
├── private/                     # 私有部分（不提交到 Git）⚠️
│   ├── custom-skills/          # 个人定制 Skills
│   └── mcp-configs/            # MCP 配置文件
├── mcp-servers/                 # MCP 服务器代码
│   ├── dm8-mcp/                # DM8 数据库 MCP
│   └── mysql-mcp/              # MySQL 数据库 MCP
└── scripts/                     # 自动化脚本
    ├── backup.sh               # 备份脚本
    ├── restore.sh              # 恢复脚本（Linux/Mac）
    └── restore.ps1             # 恢复脚本（Windows）
```

## 🚀 快速开始

### 方式一：使用模板配置（推荐新手）

1. **克隆仓库**
   ```bash
   git clone https://github.com/lrk1314/my-claude-config.git
   cd my-claude-config
   ```

2. **复制模板到 Claude Code 配置目录**

   **Windows:**
   ```bash
   # 找到你的 Claude Code 配置目录（通常是 %USERPROFILE%\.claude\）
   # 复制模板文件
   copy public\CLAUDE.template.md C:\Users\你的用户名\.claude\CLAUDE.md
   copy public\settings.template.json C:\Users\你的用户名\.claude\settings.json
   copy public\settings.local.template.json C:\Users\你的用户名\.claude\settings.local.json

   # 复制 skills
   xcopy /E /I public\skills C:\Users\你的用户名\.claude\skills
   ```

   **macOS/Linux:**
   ```bash
   # 复制模板文件
   cp public/CLAUDE.template.md ~/.claude/CLAUDE.md
   cp public/settings.template.json ~/.claude/settings.json
   cp public/settings.local.template.json ~/.claude/settings.local.json

   # 复制 skills
   cp -r public/skills ~/.claude/
   ```

3. **编辑 CLAUDE.md 填写你的信息**

   打开 `~/.claude/CLAUDE.md` 或 `%USERPROFILE%\.claude\CLAUDE.md`，替换所有 `[...]` 占位符：

   ```markdown
   # 需要替换的占位符：
   [填写你的操作系统]           → Windows 10
   [填写你的主目录路径]         → C:\Users\your_username\
   [填写你的 GitHub 用户名]     → your_github_username
   [填写你的 Git 用户名]        → your_git_username
   [填写你的 Git 邮箱]          → your_email@example.com
   # ... 等等
   ```

4. **（可选）配置 MCP 服务器**

   如果需要使用数据库 Skills（dm8/mysql），需要配置 MCP 服务器：

   ```bash
   # 安装依赖
   cd mcp-servers/mysql-mcp
   npm install

   # 配置连接信息（编辑 .env 文件）
   cp .env.example .env
   # 编辑 .env 填写数据库连接信息
   ```

5. **重启 Claude Code**

   配置完成后重启 Claude Code，你的配置就生效了喵！

### 方式二：备份现有配置

如果你已经有自己的配置，想要备份：

```bash
# Linux/Mac
./scripts/backup.sh

# Windows PowerShell
.\scripts\backup.ps1
```

### 方式三：恢复到新电脑

如果你已经备份过配置，在新电脑上恢复：

```bash
# Linux/Mac
./scripts/restore.sh

# Windows PowerShell
.\scripts\restore.ps1
```

## 📦 包含的 Skills

### Makepad 开发系列（适合 Makepad 框架开发者）
- **00-getting-started**: Makepad 入门指南
- **01-core**: 布局、组件、事件、样式核心概念
- **02-components**: 内置组件库快速参考
- **03-graphics**: 着色器、SDF 绘图、动画
- **04-patterns**: Widget 扩展、异步加载等设计模式
- **05-deployment**: 跨平台部署指南
- **06-reference**: 故障排查、代码质量、响应式布局
- **99-evolution**: 自进化 Skill 系统

### 文档处理系列
- **docx**: Word 文档创建、编辑、追踪修改
- **pdf**: PDF 表单填写、文本提取、合并拆分
- **pptx**: PowerPoint 演示文稿处理
- **xlsx**: Excel 电子表格处理（公式、格式、数据分析）

### 数据库系列
- **dm8**: DM8（达梦）数据库操作
- **mysql**: MySQL 数据库查询和管理

### 设计和创作系列
- **algorithmic-art**: p5.js 算法艺术生成
- **canvas-design**: Canvas 视觉设计（海报、艺术作品）
- **brand-guidelines**: Anthropic 品牌配色和排版规范
- **theme-factory**: 10 种预设主题（Arctic Frost、Ocean Depths 等）
- **slack-gif-creator**: 为 Slack 创建动画 GIF

### 开发工具系列
- **frontend-design**: 创建高质量前端界面
- **web-artifacts-builder**: 构建复杂 Web Artifacts（React、Tailwind、shadcn/ui）
- **playwright-cli**: 浏览器自动化、表单填写、截图
- **webapp-testing**: 本地 Web 应用测试（Playwright）
- **mcp-builder**: 创建高质量 MCP 服务器（Python FastMCP / Node.js SDK）
- **skill-creator**: Skill 创建向导

### 实用工具系列
- **doc-coauthoring**: 文档协作工作流
- **internal-comms**: 内部沟通模板（状态报告、FAQ 等）
- **web-fetch**: 获取和分析网页内容
- **translate-skills**: 将 Skill 文档翻译成中文
- **elicitation**: 心理画像分析（叙事身份研究、自我定义记忆）

## ⚙️ 配置说明

### 1. CLAUDE.md 配置

`CLAUDE.md` 是全局提示词配置文件，定义了 Claude 的行为准则和工作风格喵。

**主要配置项：**
- **核心身份**：虚拟 CTO 级合作伙伴
- **交流风格**：可爱的猫娘助手（每句话结尾加"喵"）
- **代码规范**：Craft, Don't Code 工匠宣言
- **工程准则**：八荣八耻、Shell 命令规范、文件路径规范
- **启动协议**：铁律检查、规范文件读取

**重要提醒：**
- ⚠️ 必须填写所有 `[...]` 占位符
- ⚠️ 路径必须使用绝对路径
- ⚠️ Windows 用户注意路径分隔符（`\` 或 `/`）

### 2. settings.json 配置

Claude Code 的主配置文件，定义了 MCP 服务器、环境变量等喵。

**示例配置：**
```json
{
  "mcpServers": {
    "mysql": {
      "command": "node",
      "args": ["D:/project/githup/my-claude-config/mcp-servers/mysql-mcp/build/index.js"],
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "your_password",
        "MYSQL_DATABASE": "your_database"
      }
    }
  }
}
```

### 3. settings.local.json 配置

本地权限配置文件，控制 Claude Code 的权限喵。

**示例配置：**
```json
{
  "allowedBashPrompts": [
    "run tests",
    "install dependencies",
    "build the project",
    "run database migrations"
  ]
}
```

### 4. 环境变量配置

创建 `.env` 文件（已在 `.gitignore` 中排除）：

```bash
# API 配置
ANTHROPIC_AUTH_TOKEN=your_token_here
ANTHROPIC_BASE_URL=https://api.anthropic.com

# 数据库配置
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=your_database

# DM8 配置
DM8_HOST=localhost
DM8_PORT=5236
DM8_USER=SYSDBA
DM8_PASSWORD=your_password
DM8_DATABASE=your_database
```

## 🎯 使用场景

### 场景一：文档处理

**需求**：批量处理 Word 文档，添加评论和追踪修改

```bash
# 在 Claude Code 中使用 docx skill
/docx

# 然后说：
"请读取 report.docx，在第二段添加评论'需要补充数据来源'，并启用修订模式"
```

### 场景二：数据库查询

**需求**：查询 MySQL 数据库并生成报表

```bash
# 在 Claude Code 中使用 mysql skill
/mysql

# 然后说：
"查询 users 表中最近 7 天注册的用户数量，按日期分组"
```

### 场景三：前端开发

**需求**：创建一个漂亮的登录页面

```bash
# 在 Claude Code 中使用 frontend-design skill
/frontend-design

# 然后说：
"创建一个现代风格的登录页面，包含邮箱、密码输入框和记住我选项"
```

### 场景四：测试 Web 应用

**需求**：测试本地运行的 Web 应用

```bash
# 在 Claude Code 中使用 webapp-testing skill
/webapp-testing

# 然后说：
"测试 http://localhost:3000 的登录功能，用户名 admin，密码 123456"
```

### 场景五：创建算法艺术

**需求**：生成一幅流场艺术作品

```bash
# 在 Claude Code 中使用 algorithmic-art skill
/algorithmic-art

# 然后说：
"创建一个流场粒子系统，使用柏林噪声，配色方案为蓝紫渐变"
```

## 📝 常见问题

### Q1: 如何添加自己的 Skills？

1. 在 `private/custom-skills/` 目录下创建新的 Skill
2. 参考 `/skill-creator` Skill 创建标准格式
3. 在 `settings.json` 中注册 Skill

### Q2: 如何更新 CLAUDE.md？

直接编辑 `~/.claude/CLAUDE.md` 文件，修改后重启 Claude Code 即可喵。

### Q3: 如何同步多台电脑的配置？

1. 在主力电脑上运行 `backup.sh` 备份配置
2. 将 `private/` 目录通过安全方式传输到新电脑（不要提交到 Git！）
3. 在新电脑上运行 `restore.sh` 恢复配置

### Q4: MCP 服务器无法连接？

检查以下几点：
- ✅ 数据库是否正在运行
- ✅ 连接信息是否正确（host、port、user、password）
- ✅ MCP 服务器是否正确安装依赖（`npm install`）
- ✅ 查看 Claude Code 日志输出

### Q5: Skills 不生效？

- ✅ 确认 skills 目录路径正确
- ✅ 检查 `SKILL.md` 文件格式是否正确
- ✅ 重启 Claude Code
- ✅ 使用 `/` 命令调用 Skill

## 🔒 安全说明

⚠️ **重要安全提醒：**

- ❌ **不要将 `private/` 目录提交到 Git**（已在 `.gitignore` 中排除）
- ❌ **不要在公开仓库中暴露数据库密码、API Token 等敏感信息**
- ❌ **不要分享包含个人路径、用户名等信息的配置文件**
- ✅ **使用环境变量管理敏感信息**
- ✅ **建议使用私有仓库或加密存储敏感配置**
- ✅ **定期更换密码和 Token**

## 🔄 更新日志

### 2026-02-28
- ✅ 更新 CLAUDE.template.md 到完整版本（9 大章节 + 附录）
- ✅ 上传 26 个 Skills（Makepad 系列、文档处理、数据库、设计工具等）
- ✅ 去除所有敏感信息，使用占位符替代
- ✅ 更新 README.md，添加详细的配置和使用说明

### 2026-02-27
- ✅ 初始化项目结构
- ✅ 添加 DM8 和 MySQL MCP 服务器
- ✅ 添加基础 Skills（dm8、mysql、translate-skills、elicitation）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 喵！

**贡献指南：**
1. Fork 本仓库
2. 创建新的分支（`git checkout -b feature/amazing-skill`）
3. 提交更改（`git commit -m 'Add amazing skill'`）
4. 推送到分支（`git push origin feature/amazing-skill`）
5. 创建 Pull Request

## 📚 参考资源

- [Claude Code 官方文档](https://docs.anthropic.com/claude-code)
- [MCP 协议规范](https://modelcontextprotocol.io)
- [Skills 创建指南](https://docs.anthropic.com/claude-code/skills)
- [Makepad 官方文档](https://makepad.nl)

## 📄 许可证

MIT License

Copyright (c) 2026 lirunkang

本项目中的部分 Skills 来自 Anthropic 官方示例，遵循其原始许可证喵。

## 👤 作者

- **GitHub**: [@lrk1314](https://github.com/lrk1314)
- **Email**: lirunkang1314@outlook.com

---

<div align="center">

**⭐️ 如果这个项目对你有帮助，请给个 Star 喵！⭐️**

Made with ❤️ and 🐱 by Claude Code

Let's Build Something Great 喵！

</div>
