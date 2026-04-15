# Shared Skills

这里存放的是可以同时给 Claude Code 和 Codex 使用的共享 skills。

## 使用原则

- 只放可公开、可复用、可版本化的技能
- 不放 token、私有地址、个人账号、公司内部敏感资料
- 不放 `.system` 这类客户端自带系统技能
- 生成物不要提交，例如 `__pycache__/`、`*.pyc`

## 当前包含的技能

### 架构与项目类

- `miniprogram-architect`
- `uhf-b-service-packaging`
- `work-daily-report`

### 前端与设计类

- `frontend-design`
- `canvas-design`
- `algorithmic-art`
- `theme-factory`
- `brand-guidelines`

### 文档与办公类

- `docx`
- `pdf`
- `pptx`
- `xlsx`

### 自动化与开发辅助

- `playwright-cli`
- `webapp-testing`
- `web-fetch`
- `web-artifacts-builder`
- `mcp-builder`
- `skill-creator`

### 数据库与业务支持

- `dm8`
- `mysql`
- `translate-skills`
- `elicitation`
- `doc-coauthoring`
- `internal-comms`

### 其他基础技能

- `00-getting-started`
- `01-core`
- `02-components`
- `03-graphics`
- `04-patterns`
- `05-deployment`
- `06-reference`
- `99-evolution`
- `slack-gif-creator`

## 如何新增

1. 在本目录下创建 skill 目录
2. 至少提供 `SKILL.md`
3. 如果有引用资料或脚本，把依赖文件一并提交
4. 更新本文件

## 相关文档

[Skills 使用指南](../docs/skills-guide.md)
