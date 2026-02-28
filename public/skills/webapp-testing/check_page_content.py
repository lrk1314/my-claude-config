#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time
import re

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    try:
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        textarea = page.locator('textarea.el-textarea__inner')
        textarea.click()
        textarea.fill('对海淀区进行归属地信号普查，频段30MHz-3GHz')
        textarea.press('Enter')
        time.sleep(4)

        # Get all visible text
        body_text = page.locator('body').inner_text()

        print("=== Visible Page Text ===")
        print(body_text)

        print("\n=== Looking for messages ===")
        # Look for message items
        messages = page.locator('.message-item, [class*="message"]').all()
        print(f"Found {len(messages)} message elements")

        for i, msg in enumerate(messages):
            text = msg.inner_text()
            if text.strip():
                print(f"\nMessage {i+1}:")
                print(text[:200])

    finally:
        browser.close()
