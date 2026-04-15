---
name: work-daily-report
description: 从 Claude Code 与 Codex 的本地会话记录中提取指定日期范围的工作内容，按天生成结构化工作日报。适用于“查看我最近几天做了什么”“按日期汇总日报”“根据会话记录回溯工作内容”等需求，兼容 Windows 原生路径与 WSL 路径。
---

# Work Daily Report

## Overview

当用户要求“根据会话记录整理工作日报”时，使用此 skill。它适用于同时分析 `Claude Code` 与 `Codex` 的本地 JSONL 会话记录，并将原始会话压缩为按天汇总的工作日报。

该 skill 的目标不是逐条复读聊天内容，而是提炼出：
- 当天做了哪些项目/任务
- 解决了哪些问题
- 产出了哪些文档、代码或配置
- 哪些内容只是工具配置/闲聊，应弱化或忽略

## Supported Sources

### Claude Code
默认路径：
- Windows: `C:\Users\<用户名>\.claude\projects`
- WSL: `/mnt/c/Users/<用户名>/.claude/projects`

常见特点：
- 会话文件通常为 `*.jsonl`
- 需要重点读取主会话中的 `user` 消息
- 需忽略纯 `tool_result`、`isMeta=true`、`<local-command-caveat>` 这类噪声
- `subagents` 目录通常不作为日报主来源，除非用户明确要求

### Codex
默认路径：
- Windows: `C:\Users\<用户名>\.codex\sessions`
- WSL: `/mnt/c/Users/<用户名>/.codex/sessions`

常见特点：
- 会话通常按 `年/月/日/*.jsonl` 存放
- 主要从 `response_item -> payload.type=message -> role=user` 中提取用户任务
- `session_meta.payload.cwd` 可用于识别项目目录
- 要忽略 AGENTS 注入、sandbox/permission 提示、工具警告等非工作内容

## Workflow

### Step 1: 明确统计范围
先确认：
- 日期范围（如 `4月9日到4月14日`）
- 是否需要同时读取 `Claude` 和 `Codex`
- 是否只看主会话，还是包含插件安装/环境配置类会话

默认策略：
- 同时读取 `Claude` 与 `Codex`
- 优先使用主会话
- 将插件安装、闲聊、测试性对话降权
- 若某天没有有效工作内容，明确写“未发现有效工作记录”

### Step 2: 抽取候选工作内容
按天提取这些信息：
- 用户提出的任务目标
- 相关项目目录 `cwd`
- 同一会话中的连续“请继续/继续修改/修复问题”等上下文
- 具有明显产出导向的内容：如修文档、做海报、改代码、调接口、转 HTML/PDF、配置插件、备份仓库、接入系统

不要把以下内容直接当日报主体：
- 单独的 `你好`
- 工具系统提示
- 权限/沙箱提示
- `AGENTS.md` 注入内容
- 被中断但未形成实际任务的孤立上下文

### Step 3: 归并会话为“当日工作项”
按以下维度聚合：
- 同一 `cwd` 下的连续任务视为同一项目
- 同一问题的连续修订合并成一条日报
- 同一天同一项目的多次往返，优先总结为“持续推进/迭代完善”
- 若同一天存在多个独立项目，分点列出

推荐聚类标签：
- 文档方案类
- 代码修复类
- 配置与工具链类
- 运维/仓库管理类
- 调研与接入类
- 设计与素材类

### Step 4: 提炼日报表述
将原始任务改写为适合日报的正式语句：
- 从“请你读取 xxx 并修改”改写为“完成 xxx 的分析与修改”
- 从“请继续”恢复上下文后并入上一条
- 从“试试看/帮我看一下”改写为“分析并定位问题”

表述要求：
- 使用完成式、结果导向语言
- 尽量体现对象、动作、结果
- 不要写成聊天记录
- 不要虚构未发生的结果

## Output Format

默认输出为逐日摘要：

```md
## 4月9日
- 完成 xxx 项目的方案重写与结构调整。
- 修复 xxx 系统中的 xxx 问题，并优化 xxx 逻辑。
- 梳理/生成 xxx 文档、HTML 或配置材料。
```

如果用户要求“正式日报模板”，改为：

```md
## 4月9日
今日完成：
- ...

问题风险：
- ...

明日计划：
- ...
```

## Heuristics

### 应保留的高价值信号
- 明确的项目目录
- 明确的交付物：`md/html/pdf/海报/代码/配置`
- “修复/优化/重构/转换/备份/接入/分析/调研”类动作
- 连续多轮围绕同一需求的迭代

### 应降权或忽略的低价值信号
- 问候语
- 单纯问概念定义，且与实际项目无关
- 插件/技能安装过程中的纯命令回显
- 系统 hook / stop summary / turn duration
- `The user interrupted...` 这类控制信息

### 对“配置类工作”的判断
如果配置工作本身是当天主要任务，应保留，例如：
- 安装并验证 `plugin`
- 梳理 `skills / hooks / plugin` 机制
- 为后续工作搭建环境或工作流

如果只是附带噪声，则弱化。

## Claude vs Codex Compatibility

### 在 Claude Code 场景下
优先读取：
- `C:\Users\<用户名>\.claude\projects`
- 必要时补充 `C:\Users\<用户名>\.codex\sessions`

### 在 Codex / WSL 场景下
优先读取：
- `/mnt/c/Users/<用户名>/.claude/projects`
- `/mnt/c/Users/<用户名>/.codex/sessions`

### 路径转换规则
若用户给的是 Windows 路径，而当前环境是 Linux/WSL：
- `C:\Users\lirun\.claude` → `/mnt/c/Users/lirun/.claude`
- `C:\Users\lirun\.codex` → `/mnt/c/Users/lirun/.codex`

## Recommended Extraction Strategy

优先使用脚本批量抽取，再由模型做二次压缩：
1. 脚本扫描日期范围内文件
2. 提取有效用户消息、项目目录、日期
3. 先输出“按天-按会话”的粗摘要
4. 再人工/模型压缩为“按天工作日报”

不要一开始就只靠人工读大量 JSONL；先程序化过滤噪声，更稳定。

## Script

内置脚本：`scripts/extract_daily_report.py`

推荐用法：

```bash
python extract_daily_report.py --start 2026-04-09 --end 2026-04-14
```

也可显式指定路径：

```bash
python extract_daily_report.py \
  --start 2026-04-09 \
  --end 2026-04-14 \
  --claude-dir /mnt/c/Users/lirun/.claude/projects \
  --codex-dir /mnt/c/Users/lirun/.codex/sessions
```

## Final Checklist

在输出日报前，检查：
- 是否同时覆盖 Claude 与 Codex
- 是否按日期完整覆盖用户要求的范围
- 是否把“请继续”正确并入上下文
- 是否去掉系统噪声与命令回显
- 是否把聊天式原文改写成正式日报语句
- 是否对“无有效记录”的日期做了明确说明

## Example Requests

- “请你查看我的 claude 和 codex 会话记录，帮我总结 4月9日到4月14日每天的工作日报。”
- “根据 `C:\Users\xxx\.claude` 和 `C:\Users\xxx\.codex` 里的记录，整理上周日报。”
- “把最近几天做的项目按日报格式输出，没记录的日期也列出来。”
- “先抽取会话时间线，再压缩成适合发领导的工作日报。”
