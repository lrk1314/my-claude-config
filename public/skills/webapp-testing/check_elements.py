#!/usr/bin/env python3
"""
检查页面元素
"""
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    try:
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        # 查找所有可能的输入框
        print("查找所有输入元素:")
        inputs = page.locator('input, textarea').all()
        for i, inp in enumerate(inputs):
            print(f"{i+1}. {inp.evaluate('el => el.tagName')} - type: {inp.get_attribute('type') or 'N/A'} - placeholder: {inp.get_attribute('placeholder') or 'N/A'}")

        # 截图
        page.screenshot(path='/tmp/page_elements.png', full_page=True)
        print("\n页面截图已保存: /tmp/page_elements.png")

        # 打印页面HTML结构
        print("\n页面HTML片段(body):")
        body_html = page.locator('body').inner_html()
        if 'textarea' in body_html:
            idx = body_html.find('textarea')
            print(body_html[max(0, idx-100):idx+200])

    finally:
        browser.close()
