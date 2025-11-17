# Fetch MCP Server

The Fetch MCP server enables Claude Code to make HTTP requests and retrieve web content, providing access to documentation, APIs, and external resources.

## What It Does

The Fetch MCP enables Claude Code to:
- Make HTTP GET/POST requests to external URLs
- Fetch documentation from the web
- Query public APIs for data
- Download content for analysis
- Retrieve package information from npm, GitHub, etc.

All operations respect standard HTTP protocols and web security practices.

## When to Use It

### ✅ Use Fetch MCP When:

1. **Accessing Documentation**
   - Fetching Vendure, Nx, or React documentation
   - Reading API references from official sources
   - Retrieving package README files

2. **Querying Public APIs**
   - Checking npm package versions
   - Looking up package information on npmjs.com
   - Accessing public REST APIs for data

3. **Research and Discovery**
   - Finding solutions to technical problems
   - Comparing library versions
   - Reading blog posts or tutorials

4. **Package Information**
   - Checking latest versions of dependencies
   - Reading changelogs from GitHub
   - Verifying package compatibility

5. **Content Analysis**
   - Analyzing API responses
   - Parsing HTML content
   - Extracting structured data from web pages

## When NOT to Use It

### ❌ Do NOT Use Fetch MCP When:

1. **Authenticated APIs**
   - No built-in authentication support
   - Cannot handle OAuth flows
   - Use specialized MCP or API clients for auth-required endpoints

2. **Large File Downloads**
   - Not designed for downloading large files (>10MB)
   - May timeout on slow connections
   - Use wget/curl for large downloads

3. **Rate-Limited APIs**
   - Doesn't handle rate limiting automatically
   - Can get IP-blocked if overused
   - Implement backoff/retry logic externally

4. **Streaming Data**
   - Request-response only, no streaming
   - Cannot handle WebSocket connections
   - Not suitable for real-time data

5. **Internal Network Resources**
   - Cannot access localhost or private networks (security)
   - Restricted to public internet
   - Use appropriate tools for local API testing

## Example Prompts

### 1. Fetch Package Documentation
```
"Fetch the latest documentation for nx-mcp from npm"
```

The Fetch MCP will:
- Query npmjs.com for nx-mcp package info
- Retrieve README and version details
- Return formatted documentation

---

### 2. Check Package Versions
```
"What's the latest version of @vendure/core and its changelog?"
```

The Fetch MCP will:
- Query npm registry for @vendure/core
- Get latest version number
- Fetch changelog from GitHub repository

---

### 3. API Research
```
"Show me the GitHub API endpoint structure for repositories"
```

The Fetch MCP will:
- Fetch GitHub API documentation
- Extract relevant endpoint information
- Format for easy understanding

---

### 4. Compare Technologies
```
"Fetch comparison information between PostgreSQL 15 and 16 from official docs"
```

The Fetch MCP will:
- Access PostgreSQL release notes
- Extract key differences
- Summarize changes and improvements

---

### 5. Retrieve Tutorial Content
```
"Get the Nx monorepo best practices guide from nx.dev"
```

The Fetch MCP will:
- Fetch the specified documentation page
- Extract relevant content
- Present in readable format

## Configuration

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "description": "HTTP requests and web content fetching capabilities"
    }
  }
}
```

**Arguments**:
- `@modelcontextprotocol/server-fetch`: Official Fetch MCP package
- No additional configuration required

## Safety & Security

### 🔒 Security Features

1. **Read-Only Operations**
   - Cannot modify external resources
   - Only GET requests by default
   - No write access to websites

2. **No Credential Storage**
   - Doesn't store authentication tokens
   - Each request is independent
   - No session persistence

3. **Standard HTTP Protocols**
   - Follows standard HTTP security
   - Respects HTTPS/TLS encryption
   - Validates SSL certificates

### ⚠️ Safety Considerations

1. **Rate Limiting**
   - Respect website rate limits
   - Don't spam requests to same endpoint
   - Can get IP temporarily blocked

2. **Data Privacy**
   - Fetched content is processed by Claude
   - Don't fetch sensitive/private URLs
   - Be aware of data being sent over network

3. **Malicious Content**
   - Fetched content could be malicious
   - Claude Code validates responses
   - Be cautious with unknown URLs

4. **API Terms of Service**
   - Respect API provider ToS
   - Some APIs prohibit scraping
   - Use official API clients when required

## Troubleshooting

### Issue: "Connection Timeout"

**Cause**: Remote server slow to respond or unreachable

**Solution**:
- Verify URL is correct and accessible
- Check internet connectivity
- Try again later if server is down
- Use shorter timeout if supported

---

### Issue: "404 Not Found"

**Cause**: URL doesn't exist or has changed

**Solution**:
- Verify URL spelling and path
- Check if resource moved to new location
- Try accessing in browser to confirm
- Use web search to find current URL

---

### Issue: "403 Forbidden"

**Cause**: Server blocking the request (rate limit or access denied)

**Solution**:
- Wait before retrying (rate limit)
- Check if API requires authentication
- Verify not violating ToS
- Try from different IP if blocked

---

### Issue: "SSL Certificate Error"

**Cause**: Invalid or expired SSL certificate

**Solution**:
- Verify URL uses HTTPS correctly
- Check if website has valid certificate
- May indicate security issue - proceed with caution
- Use HTTP only if absolutely necessary (not recommended)

---

### Issue: "Response Too Large"

**Cause**: Response exceeds size limits

**Solution**:
- Request specific portion of data
- Use pagination if API supports it
- Download large files with wget/curl instead
- Fetch summary or metadata only

## Best Practices

### 1. Cache Frequently Used Data
```
# If fetching same resource repeatedly, save locally
"Fetch the Vendure plugin development guide and save to docs/vendure-plugin-dev.md"
```

### 2. Verify Sources
```
✅ Good: Official documentation sites
✅ Good: GitHub repositories
⚠️ Caution: Third-party blogs (verify accuracy)
❌ Avoid: Unknown/suspicious domains
```

### 3. Respect Rate Limits
```
# Don't do this:
"Fetch data from API X 100 times"

# Do this instead:
"Fetch data from API X and cache the response"
```

### 4. Use Specific URLs
```
✅ Good: "https://nx.dev/concepts/project-graph"
❌ Avoid: "Search for Nx project graph docs" (use web search tools instead)
```

### 5. Handle Errors Gracefully
- Expect that URLs might be unavailable
- Have fallback documentation sources
- Don't rely solely on external content

## China Deployment Considerations

If deploying in China, be aware:

1. **Great Firewall (GFW)**
   - Many international sites blocked
   - GitHub, npm, Docker Hub may be slow or unreachable
   - Use China mirrors when possible

2. **Mirror URLs**
   ```
   # Use these mirrors in China:
   npm: https://registry.npmmirror.com
   GitHub: https://hub.fastgit.xyz (mirror)
   Docker: https://docker.mirrors.ustc.edu.cn
   ```

3. **VPN/Proxy**
   - Consider Tailscale setup (see `docs/guides/🇨🇳 China Deployment Guide.md`)
   - May need proxy configuration
   - Test accessibility before deployment

## Related Documentation

- [Overview](./overview.md) - All MCP servers
- [Filesystem MCP](./filesystem-mcp.md) - File operations
- [China Deployment Guide](../guides/🇨🇳%20China%20Deployment%20Guide.md) - Network considerations

## Tools Provided

The Fetch MCP server typically provides:

- `fetch` - Make HTTP GET request to URL
- `fetch_post` - Make HTTP POST request (if supported)
- `get_headers` - Retrieve only response headers
- `check_url` - Verify URL is accessible

Exact tool names may vary by implementation version.

## Common Use Cases

### Development Workflow
1. Check if new package version available
2. Read changelog to see what changed
3. Fetch migration guide if needed
4. Update package.json accordingly

### Documentation Research
1. Find official documentation URL
2. Fetch specific page or section
3. Extract relevant information
4. Save to local docs if useful

### API Integration
1. Read API documentation
2. Understand endpoint structure
3. Review example requests/responses
4. Implement integration based on docs
