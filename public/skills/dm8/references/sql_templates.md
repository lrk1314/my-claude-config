# DM8 SQL 查询模板

本文档提供 DM8 数据库的常用 SQL 查询模板和最佳实践。

## 目录

- 基础查询
- 聚合统计
- 多表关联
- 日期时间查询
- 条件筛选
- 性能优化

## 基础查询

### 分页查询

```sql
-- 使用 LIMIT OFFSET
SELECT * FROM table_name
ORDER BY id
LIMIT 20 OFFSET 0;

-- 使用 ROWNUM (DM8 特有)
SELECT * FROM (
  SELECT ROWNUM rn, t.* FROM table_name t
  WHERE ROWNUM <= 20
) WHERE rn > 0;
```

### 去重查询

```sql
SELECT DISTINCT column_name FROM table_name;

-- 多列去重
SELECT DISTINCT column1, column2 FROM table_name;
```

### 条件查询

```sql
-- 单条件
SELECT * FROM users WHERE status = 'active';

-- 多条件
SELECT * FROM users
WHERE status = 'active'
  AND created_at > '2024-01-01'
  AND role IN ('admin', 'manager');

-- 模糊查询
SELECT * FROM products WHERE name LIKE '%keyword%';
```

## 聚合统计

### 计数统计

```sql
-- 总数
SELECT COUNT(*) as total FROM table_name;

-- 分组计数
SELECT category, COUNT(*) as count
FROM products
GROUP BY category
ORDER BY count DESC;

-- 带条件的计数
SELECT COUNT(*) as active_users
FROM users
WHERE status = 'active';
```

### 求和与平均

```sql
-- 求和
SELECT SUM(amount) as total_amount FROM orders;

-- 平均值
SELECT AVG(price) as avg_price FROM products;

-- 最大最小值
SELECT MAX(price) as max_price, MIN(price) as min_price
FROM products;
```

### 复杂聚合

```sql
SELECT
  department,
  COUNT(*) as employee_count,
  AVG(salary) as avg_salary,
  SUM(salary) as total_salary,
  MAX(salary) as max_salary,
  MIN(salary) as min_salary
FROM employees
GROUP BY department
HAVING COUNT(*) > 5
ORDER BY avg_salary DESC;
```

## 多表关联

### INNER JOIN

```sql
SELECT
  o.order_id,
  o.order_date,
  u.username,
  u.email
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.status = 'completed';
```

### LEFT JOIN

```sql
SELECT
  u.username,
  COUNT(o.order_id) as order_count,
  COALESCE(SUM(o.amount), 0) as total_amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;
```

### 多表关联

```sql
SELECT
  o.order_id,
  u.username,
  p.product_name,
  od.quantity,
  od.price
FROM orders o
INNER JOIN users u ON o.user_id = u.id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.id
WHERE o.order_date >= '2024-01-01';
```

## 日期时间查询

### 日期范围

```sql
-- 今天
SELECT * FROM orders
WHERE TRUNC(order_date) = TRUNC(SYSDATE);

-- 本周
SELECT * FROM orders
WHERE order_date >= TRUNC(SYSDATE, 'IW');

-- 本月
SELECT * FROM orders
WHERE order_date >= TRUNC(SYSDATE, 'MM');

-- 最近 N 天
SELECT * FROM orders
WHERE order_date >= SYSDATE - 30;

-- 自定义日期范围
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';
```

### 日期格式化

```sql
-- 格式化日期
SELECT
  order_id,
  TO_CHAR(order_date, 'YYYY-MM-DD') as order_date_str,
  TO_CHAR(order_date, 'YYYY-MM-DD HH24:MI:SS') as order_datetime
FROM orders;

-- 按日期分组
SELECT
  TO_CHAR(order_date, 'YYYY-MM-DD') as date,
  COUNT(*) as order_count,
  SUM(amount) as total_amount
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM-DD')
ORDER BY date DESC;
```

## 条件筛选

### CASE WHEN

```sql
SELECT
  user_id,
  username,
  CASE
    WHEN age < 18 THEN '未成年'
    WHEN age >= 18 AND age < 60 THEN '成年'
    ELSE '老年'
  END as age_group
FROM users;
```

### EXISTS 子查询

```sql
-- 有订单的用户
SELECT * FROM users u
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.user_id = u.id
);

-- 没有订单的用户
SELECT * FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM orders o WHERE o.user_id = u.id
);
```

### IN 子查询

```sql
SELECT * FROM products
WHERE category_id IN (
  SELECT id FROM categories WHERE parent_id = 1
);
```

## 性能优化

### 使用索引

```sql
-- 确保常用查询字段有索引
-- 检查执行计划
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
```

### 避免全表扫描

```sql
-- 不推荐：使用函数导致索引失效
SELECT * FROM users WHERE UPPER(username) = 'ADMIN';

-- 推荐：直接使用索引字段
SELECT * FROM users WHERE username = 'admin';
```

### 限制返回行数

```sql
-- 总是在探索性查询中添加 LIMIT
SELECT * FROM large_table LIMIT 100;
```

### 使用 WHERE 而非 HAVING

```sql
-- 不推荐：在 HAVING 中过滤
SELECT department, COUNT(*)
FROM employees
GROUP BY department
HAVING department = 'IT';

-- 推荐：在 WHERE 中过滤
SELECT department, COUNT(*)
FROM employees
WHERE department = 'IT'
GROUP BY department;
```

## DM8 特殊语法

### 序列使用

```sql
-- 获取下一个序列值
SELECT seq_name.NEXTVAL FROM DUAL;

-- 获取当前序列值
SELECT seq_name.CURRVAL FROM DUAL;
```

### 层次查询

```sql
-- 树形结构查询
SELECT id, name, parent_id, LEVEL
FROM categories
START WITH parent_id IS NULL
CONNECT BY PRIOR id = parent_id
ORDER SIBLINGS BY name;
```

### ROWNUM 使用

```sql
-- 获取前 N 行
SELECT * FROM (
  SELECT * FROM table_name ORDER BY id DESC
) WHERE ROWNUM <= 10;
```
