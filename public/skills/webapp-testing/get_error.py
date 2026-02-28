#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # Capture console with types
    all_logs = []
    page.on("console", lambda msg: all_logs.append({
        'type': msg.type,
        'text': msg.text,
        'location': f"{msg.location.get('url', '')}:{msg.location.get('lineNumber', '')}" if msg.location else "unknown"
    }))

    # Capture errors
    errors = []
    page.on("pageerror", lambda exc: errors.append(str(exc)))

    try:
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        textarea = page.locator('textarea.el-textarea__inner')
        textarea.click()
        textarea.fill('对海淀区进行归属地信号普查，频段30MHz-3GHz')
        textarea.press('Enter')
        time.sleep(4)

        print("=== Page Errors ===")
        for err in errors:
            print(err)

        print("\n=== Console Logs (error/warning) ===")
        for log in all_logs:
            if log['type'] in ['error', 'warning']:
                print(f"[{log['type'].upper()}] {log['text']}")
                print(f"  at {log['location']}")

        print("\n=== All Console Logs ===")
        for log in all_logs:
            print(f"[{log['type']}] {log['text']}")

    finally:
        browser.close()
