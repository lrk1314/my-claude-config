#!/usr/bin/env python3
"""
手动测试消息发送流程
"""
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 监听控制台
    console_logs = []
    page.on("console", lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))

    try:
        print("1. 访问页面...")
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')
        page.screenshot(path='/tmp/step1.png')

        print("2. 查找textarea...")
        textarea = page.locator('textarea.el-textarea__inner')
        textarea.wait_for(state='visible', timeout=5000)
        print(f"   找到textarea，placeholder: {textarea.get_attribute('placeholder')}")

        print("3. 点击textarea获得焦点...")
        textarea.click()
        time.sleep(0.5)
        page.screenshot(path='/tmp/step2_focused.png')

        print("4. 输入文本...")
        textarea.fill('你好')
        time.sleep(0.5)
        page.screenshot(path='/tmp/step3_filled.png')

        # 检查输入的值
        value = textarea.input_value()
        print(f"   当前输入值: {value}")

        print("5. 按Enter发送...")
        textarea.press('Enter')
        time.sleep(3)
        page.screenshot(path='/tmp/step4_sent.png')

        print("6. 检查页面内容...")
        content = page.content()

        # 查找关键词
        keywords = ['你好', '您好', '无线电监测智能体系统', '归属地信号普查', 'message-item', 'chat-message']
        for kw in keywords:
            if kw in content:
                print(f"   找到: {kw}")

        print("\n7. 控制台日志:")
        for log in console_logs[-10:]:
            print(f"   {log}")

        print("\n8. 最终URL:", page.url)

    finally:
        browser.close()
