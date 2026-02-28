---
name: webapp-testing
description: 使用 Playwright 与本地 Web 应用程序交互和测试的工具包。支持验证前端功能、调试 UI 行为、捕获浏览器截图和查看浏览器日志。
license: 完整条款见 LICENSE.txt
---

# Web 应用程序测试

使用原生 Python Playwright 脚本测试本地 Web 应用程序。

**可用的辅助脚本**：
- `scripts/with_server.py` - 管理服务器生命周期（支持多个服务器）

**始终先使用 `--help` 运行脚本**以查看用法。在尝试运行脚本并发现绝对需要自定义解决方案之前，不要阅读源代码。这些脚本可能非常大，会污染你的上下文窗口。它们的存在是为了作为黑盒脚本直接调用，而不是被摄入到你的上下文窗口中。

## 决策树：选择你的方法

```
用户任务 → 是静态 HTML 吗？
    ├─ 是 → 直接读取 HTML 文件以识别选择器
    │         ├─ 成功 → 使用选择器编写 Playwright 脚本
    │         └─ 失败/不完整 → 按动态处理（见下文）
    │
    └─ 否（动态 Web 应用）→ 服务器已经在运行吗？
        ├─ 否 → 运行：python scripts/with_server.py --help
        │        然后使用辅助脚本 + 编写简化的 Playwright 脚本
        │
        └─ 是 → 侦察-然后-行动模式：
            1. 导航并等待 networkidle
            2. 截图或检查 DOM
            3. 从渲染状态识别选择器
            4. 使用发现的选择器执行操作
```

## 示例：使用 with_server.py

要启动服务器，首先运行 `--help`，然后使用辅助脚本：

**单个服务器：**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**多个服务器（例如，后端 + 前端）：**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

要创建自动化脚本，只需包含 Playwright 逻辑（服务器会自动管理）：
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # 始终以无头模式启动 chromium
    page = browser.new_page()
    page.goto('http://localhost:5173') # 服务器已经运行并准备就绪
    page.wait_for_load_state('networkidle') # 关键：等待 JS 执行完成
    # ... 你的自动化逻辑
    browser.close()
```

## 侦察-然后-行动模式

1. **检查渲染的 DOM**：
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   page.locator('button').all()
   ```

2. **从检查结果中识别选择器**

3. **使用发现的选择器执行操作**

## 常见陷阱

❌ **不要**在动态应用上等待 `networkidle` 之前检查 DOM
✅ **要**在检查之前等待 `page.wait_for_load_state('networkidle')`

## 最佳实践

- **将捆绑的脚本用作黑盒** - 要完成任务，请考虑 `scripts/` 中可用的脚本是否可以提供帮助。这些脚本可靠地处理常见的复杂工作流程，而不会使上下文窗口混乱。使用 `--help` 查看用法，然后直接调用。
- 使用 `sync_playwright()` 编写同步脚本
- 完成后始终关闭浏览器
- 使用描述性选择器：`text=`、`role=`、CSS 选择器或 ID
- 添加适当的等待：`page.wait_for_selector()` 或 `page.wait_for_timeout()`

## 参考文件

- **examples/** - 显示常见模式的示例：
  - `element_discovery.py` - 发现页面上的按钮、链接和输入框
  - `static_html_automation.py` - 对本地 HTML 使用 file:// URL
  - `console_logging.py` - 在自动化期间捕获控制台日志

## 快速开始指南

### 1. 安装依赖

```bash
# 安装 Playwright Python 包
pip install playwright

# 安装浏览器驱动（首次使用时需要）
playwright install chromium
```

### 2. 测试静态 HTML 文件

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 打开本地 HTML 文件
    page.goto('file:///path/to/your/index.html')
    page.wait_for_load_state('networkidle')

    # 截图
    page.screenshot(path='screenshot.png', full_page=True)

    browser.close()
```

### 3. 测试运行中的 Web 应用

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 访问本地开发服务器
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')

    # 查找并点击按钮
    page.click('text=登录')

    # 填写表单
    page.fill('input[name="username"]', 'testuser')
    page.fill('input[name="password"]', 'password123')

    # 提交表单
    page.click('button[type="submit"]')

    # 等待导航
    page.wait_for_url('**/dashboard')

    # 验证结果
    assert page.locator('text=欢迎').is_visible()

    browser.close()
```

### 4. 使用 with_server.py 自动启动服务器

创建测试脚本 `test_app.py`：
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')

    # 你的测试逻辑
    print("页面标题:", page.title())

    browser.close()
```

运行测试（自动启动和停止服务器）：
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python test_app.py
```

## 常用操作示例

### 发现页面元素
```python
# 查找所有按钮
buttons = page.locator('button').all()
for btn in buttons:
    print(btn.inner_text())

# 查找所有链接
links = page.locator('a').all()

# 查找输入框
inputs = page.locator('input').all()
```

### 捕获控制台日志
```python
console_logs = []

def handle_console(msg):
    console_logs.append(f"[{msg.type}] {msg.text}")

page.on("console", handle_console)
page.goto('http://localhost:3000')
```

### 等待元素出现
```python
# 等待特定元素
page.wait_for_selector('button.submit')

# 等待文本出现
page.wait_for_selector('text=加载完成')

# 等待网络空闲
page.wait_for_load_state('networkidle')
```

### 处理弹窗和对话框
```python
# 处理 alert/confirm/prompt
page.on("dialog", lambda dialog: dialog.accept())

# 点击触发弹窗的按钮
page.click('button.delete')
```

## 故障排除

### 问题：元素未找到
- 确保在查找元素之前等待 `networkidle`
- 使用 `page.screenshot()` 查看页面实际状态
- 检查元素是否在 iframe 中

### 问题：服务器未启动
- 检查端口是否被占用
- 增加 `--timeout` 参数
- 查看服务器启动日志

### 问题：测试不稳定
- 添加显式等待而不是固定延迟
- 使用 `page.wait_for_selector()` 而不是 `page.wait_for_timeout()`
- 确保在每个操作后等待页面稳定
