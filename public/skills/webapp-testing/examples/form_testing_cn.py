from playwright.sync_api import sync_playwright

# 示例：测试表单填写和提交

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 导航到包含表单的页面
    page.goto('http://localhost:3000/login')
    page.wait_for_load_state('networkidle')

    print("开始表单测试...")

    # 填写用户名
    page.fill('input[name="username"]', 'testuser')
    print("✓ 已填写用户名")

    # 填写密码
    page.fill('input[name="password"]', 'password123')
    print("✓ 已填写密码")

    # 勾选"记住我"复选框（如果存在）
    remember_me = page.locator('input[type="checkbox"]')
    if remember_me.count() > 0:
        remember_me.check()
        print("✓ 已勾选'记住我'")

    # 截图表单填写后的状态
    page.screenshot(path='/tmp/form_filled.png')
    print("✓ 已截图表单状态")

    # 点击提交按钮
    page.click('button[type="submit"]')
    print("✓ 已点击提交按钮")

    # 等待导航或响应
    try:
        page.wait_for_url('**/dashboard', timeout=5000)
        print("✓ 登录成功，已跳转到仪表板")
    except:
        # 检查是否有错误消息
        error = page.locator('.error-message, .alert-danger')
        if error.count() > 0:
            print(f"✗ 登录失败: {error.inner_text()}")
        else:
            print("✗ 登录失败: 未知错误")

    # 最终截图
    page.screenshot(path='/tmp/form_result.png')
    print("✓ 已截图最终结果")

    browser.close()

print("\n表单测试完成")
