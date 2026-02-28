#!/usr/bin/env python3
"""
检查前端响应内容
"""
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 监听控制台日志
    console_logs = []
    page.on("console", lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))

    # 监听网络请求
    requests = []
    page.on("request", lambda req: requests.append(f"{req.method} {req.url}"))

    try:
        # 访问页面
        print("访问页面...")
        page.goto('http://localhost:5173')
        page.wait_for_load_state('networkidle')

        # 输入消息
        print("输入消息...")
        page.fill('textarea', '对海淀区进行归属地信号普查，频段30MHz-3GHz')

        # 清空之前的请求记录
        requests.clear()

        # 发送消息
        print("发送消息...")
        page.press('textarea', 'Enter')

        # 等待响应
        time.sleep(5)

        # 打印控制台日志
        print("\n控制台日志:")
        for log in console_logs[-20:]:  # 最后20条
            print(f"  {log}")

        # 打印网络请求
        print("\n网络请求:")
        for req in requests[-10:]:  # 最后10个请求
            print(f"  {req}")

        # 打印页面内容片段
        content = page.content()
        print("\n页面内容片段（查找消息）:")
        # 查找包含"海淀区"的部分
        if '海淀区' in content:
            idx = content.find('海淀区')
            print(content[max(0, idx-200):idx+200])

    finally:
        browser.close()
