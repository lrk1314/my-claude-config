# MCP 配置指南

## 什么是 MCP？

MCP (Model Context Protocol) 是 Claude Code 的扩展协议，允许 Claude 与外部服务交互。

## 已配置的 MCP 服务器

### 1. DM8 MCP Server

**功能**: 连接达梦数据库，执行 SQL 查询

**配置文件**: `private/mcp-configs/dm8-config.json`

```json
{
  "connectionString": "jdbc:dm://host:port?schema=DB_NAME&ssl=true&user=USER&password=PASSWORD",
  "jdbcDriverPath": "C:\\path\\to\\DmJdbcDriver18.jar"
}
```

**可用工具**:
- `mcp__dm8__list_tables` - 列出所有表
- `mcp__dm8__describe_table` - 查看表结构
- `mcp__dm8__query` - 执行 SQL 查询

### 2. MySQL MCP Server

**功能**: 连接 MySQL 数据库，执行 SQL 查询

**配置文件**: `private/mcp-configs/mysql-config.json`

```json
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "password",
  "database": "mydb"
}
```

**可用工具**:
- `mcp__mysql__list_tables` - 列出所有表
- `mcp__mysql__describe_table` - 查看表结构
- `mcp__mysql__query` - 执行 SQL 查询

## 安装 MCP 服务器

### 自动安装（推荐）

运行恢复脚本会自动安装所有 MCP 服务器：

```bash
# Linux/Mac
./scripts/restore.sh

# Windows
.\scripts\restore.ps1
```

### 手动安装

```bash
# 进入 MCP 服务器目录
cd ~/.claude/mcp-servers/dm8-mcp

# 安装依赖
npm install

# 配置连接
cp config.example.json config.json
# 编辑 config.json 填入实际配置
```

## 配置 MCP 服务器

### 1. 创建配置文件

在 `private/mcp-configs/` 目录创建配置文件：

```bash
# DM8 配置
cat > private/mcp-configs/dm8-config.json << EOF
{
  "connectionString": "jdbc:dm://your-host:5236?schema=YOUR_DB&user=USER&password=PASSWORD",
  "jdbcDriverPath": "/path/to/DmJdbcDriver18.jar"
}
EOF

# MySQL 配置
cat > private/mcp-configs/mysql-config.json << EOF
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "your_password",
  "database": "your_database"
}
EOF
```

### 2. 复制到 MCP 目录

```bash
cp private/mcp-configs/dm8-config.json ~/.claude/mcp-servers/dm8-mcp/config.json
cp private/mcp-configs/mysql-config.json ~/.claude/mcp-servers/mysql-mcp/config.json
```

### 3. 重启 Claude Code

配置修改后需要重启 Claude Code 才能生效。

## 使用 MCP 工具

### 在 Claude Code 中使用

```bash
# 列出 DM8 数据库中的所有表
请列出 DM8 数据库中的所有表

# 查询数据
请查询 users 表中的所有数据

# 执行复杂查询
请统计每个部门的员工数量
```

Claude 会自动调用相应的 MCP 工具。

### 直接调用 MCP 工具

```bash
# 查看可用的 MCP 服务器
claude mcp list

# 测试 MCP 连接
claude mcp test dm8
```

## 创建自定义 MCP 服务器

### 1. 项目结构

```
my-mcp-server/
├── index.js           # 主文件
├── package.json       # 依赖配置
├── config.json        # 配置文件
└── README.md          # 说明文档
```

### 2. 基本代码

```javascript
// index.js
const { MCPServer } = require('@modelcontextprotocol/sdk');

const server = new MCPServer({
  name: 'my-mcp-server',
  version: '1.0.0'
});

// 注册工具
server.tool('my_tool', {
  description: '工具描述',
  parameters: {
    param1: { type: 'string', description: '参数描述' }
  },
  handler: async (params) => {
    // 工具逻辑
    return { result: 'success' };
  }
});

server.start();
```

### 3. 安装到 Claude Code

```bash
# 复制到 MCP 目录
cp -r my-mcp-server ~/.claude/mcp-servers/

# 安装依赖
cd ~/.claude/mcp-servers/my-mcp-server
npm install
```

## 故障排查

### MCP 服务器无法启动

1. **检查配置文件**
   ```bash
   cat ~/.claude/mcp-servers/dm8-mcp/config.json
   ```

2. **检查依赖**
   ```bash
   cd ~/.claude/mcp-servers/dm8-mcp
   npm install
   ```

3. **查看日志**
   ```bash
   tail -f ~/.claude/debug/mcp-*.log
   ```

### 数据库连接失败

1. **验证连接字符串**
   - 检查主机地址、端口
   - 验证用户名和密码
   - 确认数据库名称

2. **检查网络**
   ```bash
   # 测试端口连通性
   telnet host port
   ```

3. **检查驱动**
   - DM8: 确保 DmJdbcDriver18.jar 存在
   - MySQL: 确保 mysql2 包已安装

### 工具调用失败

1. **检查权限配置**
   - 查看 `settings.local.json`
   - 确保 MCP 工具在允许列表中

2. **重启 Claude Code**
   ```bash
   # 完全退出后重新启动
   ```

## 安全建议

1. **不要提交敏感信息**
   - 配置文件包含密码，不要提交到 git
   - 使用 `.gitignore` 排除配置文件

2. **使用环境变量**
   ```json
   {
     "password": "${DB_PASSWORD}"
   }
   ```

3. **限制数据库权限**
   - 为 MCP 创建专用数据库用户
   - 只授予必要的权限（SELECT, INSERT 等）

4. **使用 SSL 连接**
   - 生产环境务必启用 SSL
   - 验证服务器证书

## 相关资源

- [MCP 官方文档](https://modelcontextprotocol.io)
- [MCP SDK](https://github.com/modelcontextprotocol/sdk)
- [示例 MCP 服务器](https://github.com/modelcontextprotocol/servers)
