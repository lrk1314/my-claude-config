# Claude Code 安装指南

## 前置要求

- Node.js (v16 或更高版本)
- npm 或 yarn
- Git
- Claude Code CLI

## 安装步骤

### 1. 克隆仓库

```bash
git clone https://github.com/lrk1314/my-claude-config.git
cd my-claude-config
```

### 2. 准备私有配置

创建 `private/` 目录并添加你的配置文件：

```bash
mkdir -p private/mcp-configs private/custom-skills
```

将你的配置文件放入相应目录：
- `private/CLAUDE.md` - 全局提示词
- `private/settings.json` - 主配置
- `private/settings.local.json` - 权限配置
- `private/mcp-configs/` - MCP 配置文件

### 3. 运行恢复脚本

**Linux/Mac:**
```bash
chmod +x scripts/restore.sh
./scripts/restore.sh
```

**Windows PowerShell:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\restore.ps1
```

### 4. 验证安装

```bash
# 检查 Claude Code 配置
ls ~/.claude

# 检查 MCP 服务器
claude mcp list
```

## 常见问题

### Q: 恢复脚本报错怎么办？
A: 检查以下几点：
1. 确保 Node.js 已安装
2. 确保 private/ 目录存在且包含必要文件
3. 检查文件路径是否正确

### Q: MCP 服务器无法启动？
A: 检查：
1. config.json 配置是否正确
2. 数据库连接是否可用
3. JDBC 驱动是否存在

### Q: 如何更新配置？
A: 修改配置后运行：
```bash
./scripts/backup.sh
git add .
git commit -m "Update config"
git push
```

## 下一步

- 查看 [Skills 使用指南](skills-guide.md)
- 查看 [MCP 配置指南](mcp-guide.md)
