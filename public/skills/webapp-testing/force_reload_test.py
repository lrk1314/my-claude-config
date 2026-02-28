#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    try:
        # Force reload bypassing cache
        print("1. Loading page with cache bypass...")
        page.goto('http://localhost:5173', wait_until='networkidle')
        page.reload(wait_until='networkidle')  # Force reload
        
        print("2. Waiting for app to be ready...")
        page.wait_for_selector('textarea.el-textarea__inner', state='visible')
        time.sleep(1)

        print("3. Sending message...")
        textarea = page.locator('textarea.el-textarea__inner')
        textarea.click()
        time.sleep(0.5)
        
        # Type slowly
        textarea.type('对海淀区进行归属地信号普查，频段30MHz-3GHz', delay=50)
        time.sleep(0.5)
        
        print(f"4. Value in textarea: {textarea.input_value()}")
        
        # Press Enter
        textarea.press('Enter')
        print("5. Pressed Enter, waiting for response...")
        time.sleep(5)

        # Check for messages
        messages = page.locator('[class*="message"]').all()
        print(f"6. Found {len(messages)} message elements")

        visible_text = page.locator('body').inner_text()
        print("\n7. Page content includes:")
        for keyword in ['海淀区', '工作流', '执行ID', '失败', '错误']:
            print(f"   - {keyword}: {keyword in visible_text}")

        print(f"\n8. Current URL: {page.url}")

    finally:
        browser.close()
