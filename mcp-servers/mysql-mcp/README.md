# MySQL MCP Server

MySQL 数据库的 MCP (Model Context Protocol) 服务器实现。

## 功能特性

- 执行任意 SQL 查询
- 列出数据库中的所有表
- 查看表结构详情

## 安装

1. 确保已安装 Node.js 18 或更高版本

2. 克隆或复制此目录到 `.claude/mcp-servers/mysql-mcp`

3. 安装依赖：
```bash
cd ~/.claude/mcp-servers/mysql-mcp
npm install
```

## 配置

1. 复制配置示例文件：
```bash
cp config.json.example config.json
```

2. 编辑 `config.json`，配置你的 MySQL 连接信息：
```json
{
  "host": "127.0.0.1",
  "port": 3307,
  "user": "root",
  "password": "123456",
  "database": "your_database"
}
```

## 在 Claude Code 中配置

在 `.claude.json` 文件的 `mcpServers` 部分添加以下配置：

```json
{
  "mcpServers": {
    "mysql": {
      "args": [
        "/c",
        "node",
        "C:\\Users\\YourUsername\\.claude\\mcp-servers\\mysql-mcp\\index.js"
      ],
      "command": "cmd",
      "env": {},
      "type": "stdio"
    }
  }
}
```

## 使用方法

配置完成后，可以在 Claude Code 中使用以下命令：

1. **执行 SQL 查询**：
```
/mysql 请查询 users 表中的所有数据
```

2. **列出所有表**：
```
/mysql 列出所有表
```

3. **查看表结构**：
```
/mysql 查看 users 表的结构
```

## 可用工具

- `mcp__mysql__query` - 执行 SQL 查询
- `mcp__mysql__list_tables` - 列出所有表
- `mcp__mysql__describe_table` - 查看表结构

## 注意事项

- 确保 MySQL 服务器已启动并可访问
- 配置的用户需要有相应的数据库访问权限
- 大数据量查询建议添加 LIMIT 限制
- 修改数据前建议先用 SELECT 验证条件

## 安全建议

- 不要在配置文件中使用生产环境的数据库凭据
- 建议使用只读权限的数据库用户
- 不要将 `config.json` 文件提交到版本控制系统

## 故障排查

### 连接失败
- 检查 MySQL 服务器是否运行
- 验证 host、port 配置是否正确
- 确认用户名和密码是否正确
- 检查防火墙设置

### 权限错误
- 确保数据库用户有访问指定数据库的权限
- 检查用户是否有执行查询的权限


## 许可证

MIT
