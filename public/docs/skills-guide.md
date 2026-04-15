# Skills 使用指南

## 目标

这个仓库里的 `public/skills/` 是共享 skill 仓库，不再分 Claude 版和 Codex 版。恢复脚本会把它同步到：

- Claude Code：`~/.claude/skills`
- Codex：`~/.codex/skills`

## 当前策略

- 所有通用、可公开的 skills 放在 `public/skills/`
- 所有不想公开、但希望双端一起恢复的 skills 放在 `private/custom-skills/`
- Codex 的 `.system` 目录不进仓库

## 已新增的共享 skills

- `miniprogram-architect`
- `work-daily-report`
- `uhf-b-service-packaging`

## 如何使用

### Claude Code

Claude Code 会从 `~/.claude/skills` 读取 skills。你可以直接按 Claude Code 的习惯调用或在对话里明确提到 skill 名称。

### Codex

Codex 会从 `~/.codex/skills` 读取 skills。你可以在需求里明确提到 skill 名称，或让任务本身与 skill 描述匹配。

## 如何新增一个共享 skill

1. 在 `public/skills/` 下创建目录
2. 至少放入 `SKILL.md`
3. 如果有 `references/`、`scripts/`、模板资源，一起纳入版本控制
4. 保证 skill 不依赖你的私密路径、token 或项目外部私有文件
5. 更新 `public/skills/README.md`

## 如何新增一个私有 skill

如果这个 skill 不适合公开，放到：

```text
private/custom-skills/<skill-name>/
```

恢复脚本会把这里的技能同时复制到 `.claude/skills` 和 `.codex/skills`。

## 目录建议

```text
my-skill/
├── SKILL.md
├── references/
├── scripts/
└── assets/
```

## 最佳实践

- 尽量写成工具中立，不要把 skill 文本写死在某个单一客户端的命令格式上
- 对外部命令、依赖和环境变量写清楚前置条件
- 把大体积派生文件排除掉，比如 `__pycache__/`、`*.pyc`
- 项目专属 skill 如果要复用，先抽象掉项目路径和敏感常量

## 排查建议

### skill 没有生效

- 检查目录下是否真的存在 `SKILL.md`
- 检查目标客户端的 skills 目录下是否已经同步到该技能
- 重启客户端后再验证一次

### skill 能加载但行为不对

- 检查 skill 文档里有没有写死工具特性
- 检查依赖脚本是否一起同步了
- 检查引用的本地路径是否仍然有效
