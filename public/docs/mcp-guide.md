# MCP 配置指南

## 仓库里放什么

这个仓库对 MCP 采用“代码进仓库，连接信息进 private”的策略：

- `mcp-servers/`：版本化管理服务代码
- `private/mcp-configs/`：数据库连接、驱动路径等私有配置

当前内置的服务器有：

- `dm8-mcp`
- `mysql-mcp`

## 配置文件位置

建议把私有配置放在：

- `private/mcp-configs/dm8-config.json`
- `private/mcp-configs/mysql-config.json`

示例：

```json
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "your_password",
  "database": "your_database"
}
```

## 安装方式

### Claude Code

恢复脚本会把 `mcp-servers/` 同步到 `.claude/mcp-servers/`，并尝试恢复 `private/mcp-configs/` 里的配置文件。

你仍然需要在对应目录安装依赖：

```bash
cd mcp-servers/mysql-mcp
npm install

cd ../dm8-mcp
npm install
```

### Codex

这个仓库当前只统一管理 Codex 的 `AGENTS.md`、`config.toml` 和共享 skills。MCP 服务代码同样在仓库里，但具体怎么接入 Codex，要按你本地 Codex 版本支持的方式手动引用。

换句话说：

- 服务代码：仓库统一维护
- Claude Code 注册：脚本自动恢复
- Codex 注册：你按本地支持能力手动接

## 常见使用方式

### Claude Code settings.json

可以在 `settings.json` 里把命令指向仓库或目标目录中的构建产物，例如：

```json
{
  "mcpServers": {
    "mysql": {
      "command": "node",
      "args": [
        "D:/project/githup/my-claude-config/mcp-servers/mysql-mcp/build/index.js"
      ]
    }
  }
}
```

## 故障排查

### 服务无法启动

- 检查对应目录是否已经 `npm install`
- 检查 `config.json` 是否落到了目标目录
- 检查 `build/index.js` 是否真的存在

### 数据库连接失败

- 检查主机、端口、账号、密码
- 检查驱动文件路径
- 检查数据库用户权限

### 工具能注册但调用失败

- 检查客户端权限配置
- 检查服务启动日志
- 检查环境变量是否缺失
