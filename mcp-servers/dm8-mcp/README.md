# DM8 MCP Server

这是一个用于达梦数据库（DM8）的 Model Context Protocol (MCP) 服务器。

## 功能

- 执行 SQL 查询
- 列出数据库中的所有表
- 查看表结构
- 支持所有标准的 SQL 操作

## 配置步骤

### 1. 安装依赖

```bash
cd C:\Users\lirun\.claude\mcp-servers\dm8-mcp
npm install
```

### 2. 配置数据库连接

复制配置文件模板：
```bash
copy config.json.example config.json
```

编辑 `config.json`，填入您的 DM8 数据库信息：

```json
{
  "connectionString": "jdbc:dm://your-host:5236/SYSDBA?user=YOUR_USER&password=YOUR_PASSWORD",
  "jdbcDriverPath": "C:/path/to/DmJdbcDriver18.jar"
}
```

**重要参数说明**：
- `connectionString`: DM8 JDBC 连接字符串
  - 格式：`jdbc:dm://主机:端口/数据库名?user=用户名&password=密码`
  - 默认端口：5236
- `jdbcDriverPath`: DM8 JDBC 驱动 jar 文件的完整路径
  - 通常位于 DM8 安装目录的 `drivers` 文件夹下
  - 文件名类似：`DmJdbcDriver18.jar` 或 `DmJdbcDriver.jar`

### 3. 确保 Java 环境

确保系统已安装 Java（JDK 8 或更高版本）：
```bash
java -version
javac -version
```

### 4. 配置到 Claude Code

DM8 MCP 服务器已自动配置到 Claude Code，重启 Claude Code 后即可使用。

## 使用示例

配置完成后，在 Claude Code 中可以直接提问：

- "查询 users 表的所有数据"
- "列出数据库中的所有表"
- "查看 orders 表的结构"
- "统计每个部门的员工数量"

## 可用工具

1. **query** - 执行 SQL 查询
2. **list_tables** - 列出所有表
3. **describe_table** - 查看表结构

## 故障排查

### 找不到 JDBC 驱动
确保 `config.json` 中的 `jdbcDriverPath` 指向正确的 DM8 JDBC 驱动文件。

### 连接失败
- 检查 DM8 数据库是否正在运行
- 验证连接字符串中的主机、端口、用户名和密码
- 确保防火墙允许连接到 DM8 端口

### Java 未安装
下载并安装 JDK：https://www.oracle.com/java/technologies/downloads/

## 安全建议

- 生产环境建议使用只读账户
- 不要在配置文件中使用管理员账户
- 定期更换数据库密码
