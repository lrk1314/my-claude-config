# Skills 使用指南

## 什么是 Skills？

Skills 是 Claude Code 的扩展功能，可以为 Claude 添加特定领域的能力。

## 已包含的 Skills

### 数据库相关

#### DM8 Skill
- **功能**: 操作达梦数据库
- **使用**: `/dm8`
- **配置**: 需要在 MCP 中配置 DM8 连接

#### MySQL Skill
- **功能**: 操作 MySQL 数据库
- **使用**: `/mysql`
- **配置**: 需要在 MCP 中配置 MySQL 连接

### 工具类

#### Translate Skills
- **功能**: 翻译技能文档
- **使用**: `/translate-skills`
- **说明**: 将英文技能文档翻译为中文

#### Elicitation
- **功能**: 心理画像分析
- **使用**: `/elicitation`
- **说明**: 通过对话进行心理分析

### 官方 Skills

项目还包含多个官方 skills：
- `frontend-design` - 前端设计
- `skill-creator` - 创建新技能
- `pdf` - PDF 操作
- `pptx` - PowerPoint 操作
- `xlsx` - Excel 操作
- `docx` - Word 操作
- `web-fetch` - 网页抓取
- `playwright-cli` - 浏览器自动化
- 更多...

## 如何使用 Skill

### 基本用法

```bash
# 在 Claude Code 中使用
/skill-name [参数]

# 例如
/dm8 查询用户表
/mysql 显示所有数据库
```

### 查看可用 Skills

```bash
# 列出所有已安装的 skills
ls ~/.claude/skills
```

## 创建自定义 Skill

### 1. 使用 skill-creator

```bash
/skill-creator
```

### 2. 手动创建

在 `~/.claude/skills/` 目录下创建新文件夹：

```
my-skill/
├── SKILL.md          # 技能描述
├── metadata.json     # 元数据
└── resources/        # 资源文件
```

### 3. SKILL.md 格式

```markdown
# My Skill

## Description
技能描述

## Usage
使用说明

## Examples
示例代码
```

## 管理 Skills

### 安装新 Skill

```bash
# 从官方仓库安装
npx skills install skill-name

# 从本地安装
cp -r /path/to/skill ~/.claude/skills/
```

### 更新 Skill

```bash
# 更新所有 skills
npx skills update

# 更新特定 skill
npx skills update skill-name
```

### 删除 Skill

```bash
rm -rf ~/.claude/skills/skill-name
```

## 最佳实践

1. **定期备份**: 使用 `backup.sh` 备份自定义 skills
2. **版本控制**: 将自定义 skills 纳入版本控制
3. **文档完善**: 为自定义 skills 编写详细文档
4. **测试验证**: 在使用前测试 skill 功能

## 故障排查

### Skill 无法加载

1. 检查 SKILL.md 格式是否正确
2. 检查 metadata.json 是否存在
3. 重启 Claude Code

### Skill 执行出错

1. 查看错误日志
2. 检查依赖是否安装
3. 验证配置是否正确

## 相关资源

- [官方 Skills 仓库](https://github.com/anthropics/claude-skills)
- [Skill 开发文档](https://docs.anthropic.com/claude-code/skills)
