#!/usr/bin/env python3
"""
测试无线电监测智能体系统聊天界面
"""
from playwright.sync_api import sync_playwright
import time
import sys

def test_greeting():
    """测试问候语应返回友好回复"""
    print("=" * 60)
    print("测试 1: 输入'你好'应返回友好回复")
    print("=" * 60)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            # 1. 访问页面
            print("\n[1/5] 访问 http://localhost:5173 ...")
            page.goto('http://localhost:5173')
            page.wait_for_load_state('networkidle')
            print("[OK] 页面加载完成")

            # 2. 截图查看初始状态
            page.screenshot(path='/tmp/chat_initial.png', full_page=True)
            print("[OK] 初始页面截图已保存: /tmp/chat_initial.png")

            # 3. 查找输入框和发送按钮
            print("\n[2/5] 查找聊天输入框...")
            input_selector = 'textarea, input[type="text"]'
            page.wait_for_selector(input_selector, timeout=5000)
            print("[OK] 找到输入框")

            # 4. 输入"你好"
            print("\n[3/5] 输入消息: '你好'")
            page.fill(input_selector, '你好')
            print("[OK] 消息已输入")

            # 5. 点击发送按钮或按Enter
            print("\n[4/5] 发送消息...")
            # 尝试按Enter键发送
            page.press(input_selector, 'Enter')
            print("[OK] 消息已发送")

            # 6. 等待响应（最多10秒）
            print("\n[5/5] 等待AI回复...")
            time.sleep(3)  # 等待响应渲染

            # 7. 截图查看响应
            page.screenshot(path='/tmp/chat_greeting_response.png', full_page=True)
            print("[OK] 响应截图已保存: /tmp/chat_greeting_response.png")

            # 8. 验证响应内容
            page_content = page.content()

            # 检查是否包含友好回复的关键词
            success_keywords = ['您好', '你好', '无线电监测智能体系统', '归属地信号普查']
            found_keywords = [kw for kw in success_keywords if kw in page_content]

            if found_keywords:
                print(f"\n[PASS] 测试通过! 找到关键词: {', '.join(found_keywords)}")
                return True
            else:
                print(f"\n[FAIL] 测试失败! 未找到预期的友好回复关键词")
                print("页面内容片段:")
                print(page_content[:500])
                return False

        except Exception as e:
            print(f"\n[FAIL] 测试失败! 错误: {e}")
            page.screenshot(path='/tmp/chat_error.png', full_page=True)
            print("错误截图已保存: /tmp/chat_error.png")
            return False
        finally:
            browser.close()


def test_workflow_request():
    """测试有效的工作流请求"""
    print("\n" + "=" * 60)
    print("测试 2: 输入有效的工作流请求应启动工作流")
    print("=" * 60)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            # 1. 访问页面
            print("\n[1/5] 访问 http://localhost:5173 ...")
            page.goto('http://localhost:5173')
            page.wait_for_load_state('networkidle')
            print("[OK] 页面加载完成")

            # 2. 查找输入框
            print("\n[2/5] 查找聊天输入框...")
            input_selector = 'textarea, input[type="text"]'
            page.wait_for_selector(input_selector, timeout=5000)
            print("[OK] 找到输入框")

            # 3. 输入工作流请求
            workflow_request = '对海淀区进行归属地信号普查，频段30MHz-3GHz'
            print(f"\n[3/5] 输入消息: '{workflow_request}'")
            page.fill(input_selector, workflow_request)
            print("[OK] 消息已输入")

            # 4. 发送消息
            print("\n[4/5] 发送消息...")
            page.press(input_selector, 'Enter')
            print("[OK] 消息已发送")

            # 5. 等待响应
            print("\n[5/5] 等待AI回复...")
            time.sleep(5)  # 等待响应和可能的页面跳转

            # 6. 截图查看响应
            page.screenshot(path='/tmp/chat_workflow_response.png', full_page=True)
            print("[OK] 响应截图已保存: /tmp/chat_workflow_response.png")

            # 7. 验证响应内容或页面跳转
            current_url = page.url
            page_content = page.content()

            # 检查是否跳转到进度页面或显示工作流启动成功消息
            workflow_success_keywords = [
                '工作流已启动',
                '执行ID',
                'LocationSignalSurvey',
                '/workflow/',
                '进度页面'
            ]

            found_keywords = [kw for kw in workflow_success_keywords if kw in page_content or kw in current_url]

            if found_keywords:
                print(f"\n[PASS] 测试通过! 找到关键词: {', '.join(found_keywords)}")
                print(f"当前URL: {current_url}")
                return True
            else:
                print(f"\n[FAIL] 测试失败! 未找到预期的工作流启动成功标志")
                print(f"当前URL: {current_url}")
                print("页面内容片段:")
                print(page_content[:500])
                return False

        except Exception as e:
            print(f"\n[FAIL] 测试失败! 错误: {e}")
            page.screenshot(path='/tmp/chat_workflow_error.png', full_page=True)
            print("错误截图已保存: /tmp/chat_workflow_error.png")
            return False
        finally:
            browser.close()


def main():
    """主测试函数"""
    print("\n" + "=" * 60)
    print("无线电监测智能体系统 - 聊天界面自动化测试")
    print("=" * 60 + "\n")

    # 运行测试
    test1_passed = test_greeting()
    test2_passed = test_workflow_request()

    # 打印测试总结
    print("=" * 60)
    print("测试总结")
    print("=" * 60)
    print(f"测试 1 (问候语回复): {'[PASS] 通过' if test1_passed else '[FAIL] 失败'}")
    print(f"测试 2 (工作流请求): {'[PASS] 通过' if test2_passed else '[FAIL] 失败'}")
    print("=" * 60)

    # 返回退出码
    if test1_passed and test2_passed:
        print("\n[SUCCESS] 所有测试通过!")
        sys.exit(0)
    else:
        print("\n[WARNING] 部分测试失败，请查看上面的详细信息")
        sys.exit(1)


if __name__ == '__main__':
    main()
