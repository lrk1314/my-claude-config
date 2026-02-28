# Advanced Web Fetch Configuration

This document covers advanced configuration options and edge cases for the web-fetch skill.

## MCP Server Configuration

The MCP fetch server is configured in `claude_desktop_config.json`. Default configuration:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": ["-m", "mcp_server_fetch"]
    }
  }
}
```

## Command-Line Options

The MCP fetch server supports the following command-line options:

### Custom User-Agent

Set a custom User-Agent string for requests:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": [
        "-m", "mcp_server_fetch",
        "--user-agent", "Mozilla/5.0 (Custom Bot) MyApp/1.0"
      ]
    }
  }
}
```

### Ignore robots.txt

Bypass robots.txt restrictions (use responsibly):

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": [
        "-m", "mcp_server_fetch",
        "--ignore-robots-txt"
      ]
    }
  }
}
```

**Warning**: Only use this for authorized testing or when you have explicit permission.

### Proxy Configuration

Route requests through a proxy:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": [
        "-m", "mcp_server_fetch",
        "--proxy-url", "http://proxy.example.com:8080"
      ]
    }
  }
}
```

## Tool Parameters

### mcp__fetch__fetch

**Parameters:**

- `url` (required): The URL to fetch
- `start_index` (optional): Starting character index for chunked reading (default: 0)
- `max_length` (optional): Maximum characters to return (default: unlimited)
- `raw` (optional): Return raw HTML instead of Markdown (default: false)

**Example with all parameters:**

```python
mcp__fetch__fetch(
    url="https://example.com/article",
    start_index=1000,
    max_length=5000,
    raw=False
)
```

## Handling Different Content Types

### JavaScript-Heavy Sites

The fetch server does not execute JavaScript. For dynamic content:
- Use the site's API if available
- Look for server-side rendered alternatives
- Consider if the content is truly necessary

### PDF Documents

URLs pointing to PDF files will return the raw PDF content, which may not be useful. Consider:
- Using dedicated PDF processing tools instead
- Checking if the site offers HTML versions

### Rate Limiting

If encountering rate limits:
1. Increase delays between requests
2. Configure a custom User-Agent that identifies your use case
3. Contact the website owner for API access

## Security Considerations

The MCP fetch server:
- Can access any URL including local/internal addresses
- May represent a security risk in untrusted environments
- Should not be configured to bypass security measures without authorization

## Troubleshooting

### Connection Errors

If requests fail:
- Check internet connectivity
- Verify the URL is accessible from your network
- Check proxy configuration if using a proxy

### Empty or Malformed Content

If content extraction fails:
- Try with `raw=True` to see the original HTML
- The site may require authentication or have anti-bot measures
- Content may be loaded dynamically via JavaScript

### Character Encoding Issues

The server attempts automatic encoding detection. If text appears garbled:
- Check if the site declares its encoding correctly
- Try fetching different sections of the page
