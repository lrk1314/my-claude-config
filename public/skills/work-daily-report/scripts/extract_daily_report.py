#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从 Claude Code 与 Codex 本地会话记录中提取工作日报素材。

示例:
  python extract_daily_report.py --start 2026-04-09 --end 2026-04-14
  python extract_daily_report.py --start 2026-04-09 --end 2026-04-14 \
    --claude-dir /mnt/c/Users/lirun/.claude/projects \
    --codex-dir /mnt/c/Users/lirun/.codex/sessions
"""

import argparse
import json
import os
import re
from collections import defaultdict
from datetime import datetime
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description='从 Claude Code 与 Codex 会话提取日报素材')
    parser.add_argument('--start', required=True, help='开始日期 YYYY-MM-DD')
    parser.add_argument('--end', required=True, help='结束日期 YYYY-MM-DD')
    parser.add_argument('--claude-dir', default=str(Path.home() / '.claude' / 'projects'), help='Claude projects 目录')
    parser.add_argument('--codex-dir', default=str(Path.home() / '.codex' / 'sessions'), help='Codex sessions 目录')
    parser.add_argument('--include-subagents', action='store_true', help='包含 Claude subagents 目录')
    return parser.parse_args()


def parse_date(date_str):
    return datetime.strptime(date_str, '%Y-%m-%d')


def parse_timestamp(value):
    if not value:
        return None
    if isinstance(value, (int, float)):
        if value > 1e12:
            value = value / 1000
        return datetime.fromtimestamp(value)
    if isinstance(value, str):
        for fmt in (
            '%Y-%m-%dT%H:%M:%S.%fZ', '%Y-%m-%dT%H:%M:%SZ',
            '%Y-%m-%dT%H:%M:%S.%f', '%Y-%m-%dT%H:%M:%S'
        ):
            try:
                return datetime.strptime(value, fmt)
            except ValueError:
                continue
    return None


def clean_text(text):
    if not text:
        return ''
    text = re.sub(r'<local-command-caveat>.*?</local-command-caveat>', ' ', text, flags=re.S)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def shorten(text, limit=220):
    text = text.strip()
    return text if len(text) <= limit else text[:limit] + '...'


def iter_claude_sessions(root, include_subagents=False):
    root = Path(root)
    if not root.exists():
        return
    for path in root.rglob('*.jsonl'):
        if not include_subagents and 'subagents' in path.parts:
            continue
        yield path


def iter_codex_sessions(root):
    root = Path(root)
    if not root.exists():
        return
    for path in root.rglob('*.jsonl'):
        yield path


def extract_claude_prompts(path, start_dt, end_dt):
    prompts = []
    cwd = None
    for raw in path.open('r', encoding='utf-8', errors='ignore'):
        try:
            obj = json.loads(raw)
        except Exception:
            continue
        cwd = obj.get('cwd') or cwd
        if obj.get('type') != 'user' or obj.get('isMeta'):
            continue
        msg = obj.get('message', {})
        content = msg.get('content')
        text = ''
        if isinstance(content, str):
            text = content
        elif isinstance(content, list):
            parts = []
            for item in content:
                if not isinstance(item, dict):
                    continue
                if item.get('type') == 'text':
                    parts.append(item.get('text', ''))
            text = ' '.join(parts)
        text = clean_text(text)
        if not text:
            continue
        ts = parse_timestamp(obj.get('timestamp'))
        if ts and not (start_dt <= ts <= end_dt):
            continue
        prompts.append(text)
    return cwd, prompts


def extract_codex_prompts(path):
    prompts = []
    cwd = None
    started = None
    for raw in path.open('r', encoding='utf-8', errors='ignore'):
        try:
            obj = json.loads(raw)
        except Exception:
            continue
        if obj.get('type') == 'session_meta':
            payload = obj.get('payload', {})
            cwd = payload.get('cwd') or cwd
            started = parse_timestamp(payload.get('timestamp')) or started
            continue
        if obj.get('type') != 'response_item':
            continue
        payload = obj.get('payload', {})
        if payload.get('type') != 'message' or payload.get('role') != 'user':
            continue
        texts = []
        for item in payload.get('content', []):
            if not isinstance(item, dict):
                continue
            texts.append(item.get('text') or item.get('input_text') or '')
        text = clean_text(' '.join(texts))
        if text:
            prompts.append(text)
    return cwd, started, prompts


def collect_claude(claude_dir, start_dt, end_dt, include_subagents=False):
    items = []
    for path in iter_claude_sessions(claude_dir, include_subagents=include_subagents) or []:
        try:
            mtime = datetime.fromtimestamp(path.stat().st_mtime)
        except Exception:
            mtime = None
        if mtime and not (start_dt <= mtime <= end_dt):
            continue
        cwd, prompts = extract_claude_prompts(path, start_dt, end_dt)
        if prompts:
            day = (mtime or start_dt).strftime('%Y-%m-%d')
            items.append({'source': 'claude', 'day': day, 'cwd': cwd, 'file': str(path), 'prompts': prompts})
    return items


def collect_codex(codex_dir, start_dt, end_dt):
    items = []
    for path in iter_codex_sessions(codex_dir) or []:
        cwd, started, prompts = extract_codex_prompts(path)
        if not started or not (start_dt <= started <= end_dt):
            continue
        if prompts:
            day = started.strftime('%Y-%m-%d')
            items.append({'source': 'codex', 'day': day, 'cwd': cwd, 'file': str(path), 'prompts': prompts})
    return items


def render(items, start_str, end_str):
    by_day = defaultdict(list)
    for item in sorted(items, key=lambda x: (x['day'], x['source'], x['file'])):
        by_day[item['day']].append(item)

    lines = []
    lines.append(f'# 会话日报素材 {start_str} ~ {end_str}')
    lines.append('')
    if not by_day:
        lines.append('未发现指定日期范围内的有效会话。')
        return '\n'.join(lines)

    day_cursor = parse_date(start_str)
    end_day = parse_date(end_str)
    while day_cursor <= end_day:
        day = day_cursor.strftime('%Y-%m-%d')
        lines.append(f'## {day}')
        day_items = by_day.get(day, [])
        if not day_items:
            lines.append('- 未发现有效工作记录')
            lines.append('')
            day_cursor = day_cursor.fromordinal(day_cursor.toordinal() + 1)
            continue
        for idx, item in enumerate(day_items, 1):
            lines.append(f"- [{idx}] {item['source']} | cwd={item['cwd'] or 'unknown'}")
            for prompt in item['prompts'][:4]:
                lines.append(f"  - {shorten(prompt)}")
            if len(item['prompts']) > 4:
                lines.append(f"  - ... total prompts {len(item['prompts'])}")
        lines.append('')
        day_cursor = day_cursor.fromordinal(day_cursor.toordinal() + 1)
    return '\n'.join(lines)


def main():
    args = parse_args()
    start_dt = parse_date(args.start)
    end_dt = parse_date(args.end).replace(hour=23, minute=59, second=59)

    items = []
    items.extend(collect_claude(args.claude_dir, start_dt, end_dt, include_subagents=args.include_subagents))
    items.extend(collect_codex(args.codex_dir, start_dt, end_dt))
    print(render(items, args.start, args.end))


if __name__ == '__main__':
    main()
