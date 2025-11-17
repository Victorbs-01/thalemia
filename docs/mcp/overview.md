# MCP Servers Overview

Model Context Protocol (MCP) servers extend Claude Code's capabilities by providing specialized tools and integrations. This document provides an overview of all configured MCP servers in the Entrepreneur-OS project.

## What is MCP?

The Model Context Protocol is a standardized way for AI assistants to interact with external tools, data sources, and services. MCP servers run as separate processes and communicate with Claude Code to provide additional functionality beyond built-in capabilities.

## Configured MCP Servers

Entrepreneur-OS uses **5 MCP servers** to enhance development workflows:

### 1. Filesystem MCP
**Purpose**: Secure file system operations with controlled access to the workspace.

**Use when**: Reading, writing, searching, or managing files within the project directory.

📄 [Full Documentation](./filesystem-mcp.md)

---

### 2. Fetch MCP
**Purpose**: HTTP requests and web content fetching capabilities.

**Use when**: Fetching documentation, making API calls, or retrieving web content during development.

📄 [Full Documentation](./fetch-mcp.md)

---

### 3. Git MCP
**Purpose**: Git repository operations including commits, branches, and history.

**Use when**: Version control operations, commit analysis, or branch management.

📄 [Full Documentation](./git-mcp.md)

---

### 4. Nx MCP ✨ NEW
**Purpose**: Nx monorepo project graph, task management, and workspace intelligence.

**Use when**: Understanding project dependencies, running Nx tasks, or exploring the monorepo structure.

📄 [Full Documentation](./nx-mcp.md)

---

### 5. Task Master MCP ✨ NEW
**Purpose**: AI-powered task management with PRD parsing and task decomposition.

**Use when**: Managing complex development tasks, breaking down requirements, or tracking project progress.

📄 [Full Documentation](./task-master-mcp.md)

---

## Quick Reference

| MCP Server | Primary Use Case | Requires API Key |
|------------|------------------|------------------|
| Filesystem | File operations within workspace | No |
| Fetch | HTTP requests and web content | No |
| Git | Version control operations | No |
| Nx MCP | Monorepo project graph & tasks | No |
| Task Master | AI-powered task management | Yes (optional) |

## Configuration

All MCP servers are configured in `.claude/settings.json` under the `mcpServers` section. The configuration uses `npx` to run servers without adding them as project dependencies.

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["package-name"],
      "description": "What this server does"
    }
  }
}
```

## Environment Variables

Some MCP servers require API keys:

- **Task Master**: Requires `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`

Set these in your `.env` file or environment. See `.env.example` for templates.

## Best Practices

### 1. Use the Right Tool for the Job
- **File operations** → Filesystem MCP
- **Web requests** → Fetch MCP
- **Git operations** → Git MCP
- **Monorepo tasks** → Nx MCP
- **Task planning** → Task Master MCP

### 2. Security Considerations
- Filesystem MCP is restricted to the project directory (`/home/user/thalemia`)
- Git MCP only operates on this repository
- Never expose API keys in configuration files
- Use environment variables for sensitive data

### 3. Performance Tips
- MCP servers start on-demand when Claude Code needs them
- Servers may cache data for faster responses
- Use Nx MCP for monorepo awareness instead of manual file searches
- Leverage Task Master for complex, multi-step planning

## Troubleshooting

### MCP Server Won't Start
1. Ensure `npx` is available: `which npx`
2. Check network connectivity (npx downloads packages on first use)
3. Verify Node.js version: `node --version` (requires Node 18+)

### Environment Variable Issues
1. Check `.env` file exists and is loaded
2. Verify variable names match exactly (case-sensitive)
3. Restart Claude Code after changing environment variables

### China Deployment Notes
If deploying in China and experiencing npm registry issues:

```bash
# Use China npm mirror
export NPM_REGISTRY=https://registry.npmmirror.com
export USE_CHINA_MIRRORS=true
```

See `docs/guides/🇨🇳 China Deployment Guide.md` for complete setup.

## Related Documentation

- [CLAUDE.md](../../CLAUDE.md) - Main Claude Code project guidance
- [Architecture Overview](../architecture/ARCHITECTURE.md)
- [Nx Workspace Documentation](https://nx.dev)

## Support

For MCP-specific issues:
- Check individual MCP server documentation (links above)
- Review Claude Code logs
- Verify environment configuration

For project-specific issues:
- See troubleshooting in CLAUDE.md
- Check relevant documentation in `docs/`
