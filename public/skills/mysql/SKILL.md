---
name: mysql
description: MySQL 数据库操作工具。用于查询数据、分析数据、管理数据库结构。当用户需要操作 MySQL 数据库、执行 SQL 查询、查看表结构、列出数据库对象时使用此 skill。
---

# MySQL 数据库操作

## 概述

此 skill 提供 MySQL 数据库的完整操作能力，包括数据查询、结构管理和分析。

## 核心功能

### 1. 执行 SQL 查询

使用 `mcp__mysql__query` 工具执行任意 SQL 查询：

```python
# 查询数据示例
mcp__mysql__query(sql="SELECT * FROM users WHERE status = 'active' LIMIT 10")

# 统计分析示例
mcp__mysql__query(sql="SELECT department, COUNT(*) as count FROM employees GROUP BY department")
```

### 2. 列出所有表

使用 `mcp__mysql__list_tables` 查看数据库中的所有表：

```python
mcp__mysql__list_tables()
```

### 3. 查看表结构

使用 `mcp__mysql__describe_table` 获取表的详细结构：

```python
mcp__mysql__describe_table(table_name="users")
```

## 工作流程

### 探索数据库
1. 使用 `list_tables` 查看所有表
2. 对感兴趣的表使用 `describe_table` 了解结构
3. 使用 `query` 执行查询获取数据

### 数据分析
1. 根据需求编写 SQL 查询语句
2. 使用 `query` 执行并获取结果
3. 对结果进行分析和展示

## 常用查询模板

对于更复杂的查询场景，参见 **[references/sql_templates.md](references/sql_templates.md)**，包含：
- 常用的数据分析查询
- 表关联查询模板
- 聚合统计模板
- 性能优化建议

## 注意事项

- 所有 SQL 语句需遵循 MySQL 语法规范
- 大数据量查询建议添加 LIMIT 限制
- 修改数据前建议先用 SELECT 验证条件
- MySQL 表名和列名默认大小写敏感（取决于操作系统）
