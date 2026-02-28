#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time
import json

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # Capture console logs
    logs = []
    page.on("console", lambda msg: logs.append(f"[{msg.type}] {msg.text}"))

    # Capture network
    api_calls = []

    def capture_response(response):
        if '/api/workflow' in response.url:
            api_calls.append({
                'url': response.url,
                'status': response.status
            })

    page.on("response", capture_response)

    try:
        print("1. Visit page")
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        print("2. Fill workflow request")
        textarea = page.locator('textarea.el-textarea__inner')
        textarea.click()
        textarea.fill('对海淀区进行归属地信号普查，频段30MHz-3GHz')
        textarea.press('Enter')
        time.sleep(6)

        print(f"\n3. Current URL: {page.url}")

        print("\n4. API Calls:")
        for call in api_calls:
            print(f"   {call['url']} - Status: {call['status']}")

        print("\n5. Console Logs:")
        for log in logs[-15:]:
            print(f"   {log}")

        content = page.content()
        print("\n6. Keywords found:")
        keywords = ['工作流已启动', 'executionId', '失败', '错误', 'Error']
        for kw in keywords:
            if kw in content or kw.lower() in content.lower():
                print(f"   - {kw}: YES")

    finally:
        browser.close()
