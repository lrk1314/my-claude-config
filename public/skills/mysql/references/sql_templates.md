# MySQL SQL 查询模板

## 数据查询模板

### 基础查询
```sql
-- 查询所有数据
SELECT * FROM table_name;

-- 条件查询
SELECT * FROM table_name WHERE condition;

-- 排序查询
SELECT * FROM table_name ORDER BY column_name ASC/DESC;

-- 限制结果数量
SELECT * FROM table_name LIMIT 10;

-- 分页查询
SELECT * FROM table_name LIMIT 10 OFFSET 20;
```

### 聚合查询
```sql
-- 统计数量
SELECT COUNT(*) FROM table_name;

-- 分组统计
SELECT column_name, COUNT(*) as count
FROM table_name
GROUP BY column_name;

-- 多重聚合
SELECT
    department,
    COUNT(*) as total,
    AVG(salary) as avg_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY department;
```

### 表关联查询
```sql
-- INNER JOIN
SELECT t1.*, t2.*
FROM table1 t1
INNER JOIN table2 t2 ON t1.id = t2.foreign_id;

-- LEFT JOIN
SELECT t1.*, t2.*
FROM table1 t1
LEFT JOIN table2 t2 ON t1.id = t2.foreign_id;

-- 多表关联
SELECT u.name, o.order_id, p.product_name
FROM users u
INNER JOIN orders o ON u.id = o.user_id
INNER JOIN products p ON o.product_id = p.id;
```

### 子查询
```sql
-- WHERE 子查询
SELECT * FROM orders
WHERE user_id IN (SELECT id FROM users WHERE status = 'active');

-- FROM 子查询
SELECT dept, avg_salary
FROM (
    SELECT department as dept, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department
) as dept_stats
WHERE avg_salary > 50000;
```

## 数据修改模板

### 插入数据
```sql
-- 插入单条数据
INSERT INTO table_name (column1, column2) VALUES (value1, value2);

-- 插入多条数据
INSERT INTO table_name (column1, column2) VALUES
(value1, value2),
(value3, value4);
```

### 更新数据
```sql
-- 更新数据
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

### 删除数据
```sql
-- 删除数据
DELETE FROM table_name WHERE condition;
```

## 表结构查询

### 查看数据库信息
```sql
-- 查看所有数据库
SHOW DATABASES;

-- 查看当前数据库
SELECT DATABASE();

-- 查看所有表
SHOW TABLES;

-- 查看表结构
DESCRIBE table_name;
-- 或
SHOW COLUMNS FROM table_name;
```

### 查看索引和约束
```sql
-- 查看表索引
SHOW INDEX FROM table_name;

-- 查看表创建语句
SHOW CREATE TABLE table_name;
```

## 性能优化建议

1. **使用索引**
   - 为常用查询条件的列创建索引
   - 避免在索引列上使用函数

2. **限制返回结果**
   - 使用 LIMIT 限制结果数量
   - 只查询需要的列，避免 SELECT *

3. **优化 JOIN**
   - 确保 JOIN 条件列有索引
   - 小表驱动大表

4. **避免 N+1 查询**
   - 使用 JOIN 替代循环查询

5. **使用 EXPLAIN 分析查询**
```sql
EXPLAIN SELECT * FROM table_name WHERE condition;
```

## 常见数据分析查询

### 时间范围查询
```sql
-- 查询今天的数据
SELECT * FROM orders
WHERE DATE(created_at) = CURDATE();

-- 查询最近 7 天的数据
SELECT * FROM orders
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- 按月统计
SELECT
    DATE_FORMAT(created_at, '%Y-%m') as month,
    COUNT(*) as count
FROM orders
GROUP BY month
ORDER BY month;
```

### 排名查询
```sql
-- 使用窗口函数排名（MySQL 8.0+）
SELECT
    name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- 每个部门的排名
SELECT
    department,
    name,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank
FROM employees;
```

### 去重查询
```sql
-- 简单去重
SELECT DISTINCT column_name FROM table_name;

-- 复杂去重（保留最新记录）
SELECT *
FROM orders o1
WHERE created_at = (
    SELECT MAX(created_at)
    FROM orders o2
    WHERE o1.user_id = o2.user_id
);
```
