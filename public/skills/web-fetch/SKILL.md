---
name: web-fetch
description: "Fetch and extract web content as Markdown. Use when users request: (1) Fetching webpage content, (2) Converting web pages to text/Markdown, (3) Extracting article content from URLs, (4) Scraping web data, or (5) Any task requiring reading web pages."
---

# Web Fetch

## Overview

Fetch web content and convert it to Markdown format for efficient LLM processing. Powered by MCP fetch server with readability extraction.

## Quick Start

Use the `mcp__fetch__fetch` tool to retrieve web pages:

```python
# Basic fetch - returns entire page as Markdown
mcp__fetch__fetch(url="https://example.com")

# Chunked reading - fetch specific portions
mcp__fetch__fetch(
    url="https://example.com/long-article",
    start_index=0,    # Start at character 0
    max_length=5000   # Read first 5000 characters
)
```

## Key Features

- **Markdown conversion**: Automatically converts HTML to clean Markdown
- **Readability extraction**: Extracts main content, removing ads and navigation
- **Chunked reading**: Process large pages in manageable chunks
- **Robots.txt compliance**: Respects website crawling rules by default

## When to Use Chunked Reading

For long articles or documentation:
1. Fetch with `start_index=0, max_length=5000` to get the beginning
2. Scan the content to locate relevant sections
3. Fetch subsequent chunks as needed using different `start_index` values

This approach minimizes context usage by loading only necessary content.

## Advanced Configuration

For custom User-Agent, proxy settings, or robots.txt handling, see [ADVANCED.md](references/ADVANCED.md).

## Common Patterns

**Extract article content:**
```python
# Let readability extract the main content automatically
mcp__fetch__fetch(url="https://blog.example.com/article")
```

**Compare multiple sources:**
```python
# Fetch from multiple URLs to compare information
mcp__fetch__fetch(url="https://source1.com/topic")
mcp__fetch__fetch(url="https://source2.com/topic")
```

**Progressive exploration:**
```python
# First, fetch the beginning to understand structure
mcp__fetch__fetch(url="https://docs.example.com", max_length=3000)
# Then, fetch specific sections based on what you found
mcp__fetch__fetch(url="https://docs.example.com", start_index=3000, max_length=3000)
```
