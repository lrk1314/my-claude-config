# Hooks 目录

本目录包含 Claude Code 的钩子脚本。

## 什么是 Hooks？

Hooks 是在特定事件发生时自动执行的脚本，可以用于：
- 验证输入参数
- 检查文件路径
- 执行预处理或后处理
- 记录操作日志

## 已包含的 Hooks

### PathValidation.ps1
- **功能**: 验证文件路径是否使用绝对路径
- **触发时机**: 在执行 Read/Write/Edit/Glob 等文件操作前
- **平台**: Windows PowerShell

## 如何使用

Hooks 会在 `settings.json` 中配置：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "command": "pwsh -NoProfile -ExecutionPolicy Bypass -File \"%USERPROFILE%\\.claude\\hooks\\PathValidation.ps1\"",
            "type": "command"
          }
        ],
        "matcher": "Read|Write|Edit|Glob"
      }
    ]
  }
}
```

## 创建自定义 Hook

1. 在此目录创建脚本文件
2. 在 `settings.json` 中配置
3. 测试验证

## 注意事项

- Hooks 会影响性能，谨慎使用
- 确保脚本有执行权限
- 错误的 hook 可能导致工具无法使用
