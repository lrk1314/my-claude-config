#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    try:
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        textarea = page.locator('textarea.el-textarea__inner')
        textarea.click()
        textarea.fill('对海淀区进行归属地信号普查，频段30MHz-3GHz')

        send_button = page.locator('button:has-text("发送")')
        send_button.click()

        time.sleep(5)

        # Get all text
        text = page.locator('body').inner_text()

        print("=== Page Text ===")
        print(text)

        print("\n=== Messages ===")
        # Find message elements
        messages = page.locator('.message-item, [class*="ChatMessage"]').all()
        for i, msg in enumerate(messages):
            msg_text = msg.inner_text()
            if msg_text.strip():
                print(f"\nMessage {i+1}:")
                print(msg_text)

    finally:
        browser.close()
