#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from playwright.sync_api import sync_playwright
import time

def test_greeting():
    """测试问候语回复"""
    print("\n[测试1] 问候语回复")
    print("=" * 60)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            # 访问页面
            page.goto('http://localhost:5173')
            page.wait_for_load_state('networkidle')

            # 输入消息
            textarea = page.locator('textarea.el-textarea__inner')
            textarea.click()
            textarea.fill('你好')

            # 点击发送按钮（而不是按Enter）
            send_button = page.locator('button:has-text("发送")')
            send_button.click()

            # 等待响应
            time.sleep(3)

            # 验证响应
            visible_text = page.locator('body').inner_text()

            if '无线电监测智能体系统' in visible_text and '归属地信号普查' in visible_text:
                print("[PASS] 找到友好回复!")
                return True
            else:
                print("[FAIL] 未找到预期的回复")
                return False

        finally:
            browser.close()


def test_workflow():
    """测试工作流请求"""
    print("\n[测试2] 工作流请求")
    print("=" * 60)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            # 访问页面
            page.goto('http://localhost:5173')
            page.wait_for_load_state('networkidle')

            # 输入消息
            textarea = page.locator('textarea.el-textarea__inner')
            textarea.click()
            textarea.fill('对海淀区进行归属地信号普查，频段30MHz-3GHz')

            # 点击发送按钮
            send_button = page.locator('button:has-text("发送")')
            send_button.click()

            # 等待响应和可能的页面跳转
            time.sleep(6)

            # 验证结果
            url = page.url
            visible_text = page.locator('body').inner_text()

            # 检查是否跳转到进度页面或显示成功消息
            if '/workflow/' in url or '工作流已启动' in visible_text or 'executionId' in visible_text.lower():
                print(f"[PASS] 工作流启动成功! URL: {url}")
                return True
            else:
                print(f"[FAIL] 工作流未启动")
                print(f"  当前URL: {url}")
                # 检查是否有错误消息
                if '失败' in visible_text or '错误' in visible_text:
                    print(f"  发现错误消息")
                return False

        finally:
            browser.close()


if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("无线电监测智能体系统 - 自动化测试")
    print("=" * 60)

    # 运行测试
    test1_passed = test_greeting()
    test2_passed = test_workflow()

    # 输出结果
    print("\n" + "=" * 60)
    print("测试结果")
    print("=" * 60)
    print(f"[测试1] 问候语回复: {'[PASS] 通过' if test1_passed else '[FAIL] 失败'}")
    print(f"[测试2] 工作流请求: {'[PASS] 通过' if test2_passed else '[FAIL] 失败'}")
    print("=" * 60)

    if test1_passed and test2_passed:
        print("\n[SUCCESS] 所有测试通过!")
        exit(0)
    else:
        print("\n[WARNING] 部分测试失败")
        exit(1)
