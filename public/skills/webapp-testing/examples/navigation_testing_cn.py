from playwright.sync_api import sync_playwright

# 示例：测试页面导航和路由

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 访问首页
    print("1. 访问首页...")
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')
    print(f"   当前 URL: {page.url}")
    print(f"   页面标题: {page.title()}")

    # 点击导航链接
    print("\n2. 点击'关于'链接...")
    page.click('a[href="/about"]')
    page.wait_for_load_state('networkidle')
    print(f"   当前 URL: {page.url}")
    assert '/about' in page.url, "导航到关于页面失败"
    print("   ✓ 成功导航到关于页面")

    # 使用浏览器后退按钮
    print("\n3. 点击浏览器后退按钮...")
    page.go_back()
    page.wait_for_load_state('networkidle')
    print(f"   当前 URL: {page.url}")
    print("   ✓ 成功返回首页")

    # 使用浏览器前进按钮
    print("\n4. 点击浏览器前进按钮...")
    page.go_forward()
    page.wait_for_load_state('networkidle')
    print(f"   当前 URL: {page.url}")
    print("   ✓ 成功前进到关于页面")

    # 直接导航到特定 URL
    print("\n5. 直接导航到联系页面...")
    page.goto('http://localhost:3000/contact')
    page.wait_for_load_state('networkidle')
    print(f"   当前 URL: {page.url}")
    print("   ✓ 成功导航到联系页面")

    # 测试不存在的页面（404）
    print("\n6. 测试 404 页面...")
    page.goto('http://localhost:3000/nonexistent')
    page.wait_for_load_state('networkidle')

    # 检查是否显示 404 消息
    not_found = page.locator('text=/404|not found/i')
    if not_found.count() > 0:
        print("   ✓ 正确显示 404 页面")
    else:
        print("   ⚠ 未找到 404 提示")

    browser.close()

print("\n导航测试完成")
