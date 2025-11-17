# Nx MCP Server ✨ NEW

The Nx MCP server provides deep integration with the Nx monorepo workspace, offering project graph awareness, dependency analysis, and intelligent task execution capabilities specifically designed for Entrepreneur-OS.

## What It Does

The Nx MCP enables Claude Code to:
- **Understand monorepo structure**: Project graph, dependencies, relationships
- **Execute Nx tasks**: Build, test, lint, serve applications
- **Analyze impact**: Determine which projects are affected by changes
- **Access generators**: Use Nx generators to scaffold code
- **Query workspace**: Find projects, libraries, and their configurations
- **Provide documentation**: Built-in Nx documentation and best practices

This is **the official MCP from the Nx team** (Nrwl), ensuring deep and accurate monorepo understanding.

## When to Use It

### ✅ Use Nx MCP When:

1. **Understanding Project Structure**
   - "What projects do we have in this monorepo?"
   - "Show me the dependencies of vendure-master"
   - "Which libraries does the Next.js storefront use?"

2. **Running Nx Tasks**
   - Building affected projects
   - Running tests for specific libraries
   - Linting modified code
   - Serving applications in development

3. **Analyzing Changes**
   - "Which projects are affected by my changes?"
   - "What do I need to rebuild?"
   - "Which tests should run based on git diff?"

4. **Exploring Dependencies**
   - "What depends on @entrepreneur-os/shared/utils?"
   - "Can I remove this library safely?"
   - "What's the dependency path between vendure-master and ui-components?"

5. **Generating Code**
   - "What generators are available?"
   - "How do I create a new React library?"
   - "Show me the schema for the component generator"

## When NOT to Use It

### ❌ Do NOT Use Nx MCP When:

1. **File Content Analysis**
   - Reading specific file contents → Use Filesystem MCP
   - Editing source code → Use Filesystem MCP
   - Searching code → Use Grep tools

2. **Git Operations**
   - Commit history → Use Git MCP
   - Branch management → Use Git MCP
   - Diff analysis → Use Git MCP

3. **External API Calls**
   - Fetching documentation → Use Fetch MCP
   - Making HTTP requests → Use Fetch MCP

4. **Non-Nx Projects**
   - Nx MCP only works with Nx workspaces
   - Won't help with standalone projects

5. **Complex Build Debugging**
   - Low-level build tool issues → Check build logs directly
   - Webpack/Vite configuration → Edit configs manually
   - Node module issues → Use npm/pnpm directly

## Example Prompts

### 1. Understand Monorepo Structure
```
"Show me all applications and libraries in the Entrepreneur-OS monorepo"
```

The Nx MCP will:
- Query the workspace project graph
- List all apps: vendure-master, vendure-ecommerce, storefronts, etc.
- List all libs: shared, vendure plugins, testing utilities
- Show project types and tags

---

### 2. Analyze Dependencies
```
"What are the dependencies of vendure-master? Show the complete dependency tree"
```

The Nx MCP will:
- Access the project graph
- Identify direct dependencies
- Resolve transitive dependencies
- Display as tree structure
- Highlight circular dependencies if any

---

### 3. Run Affected Tasks
```
"Run tests for all projects affected by my recent changes"
```

The Nx MCP will:
- Determine affected projects based on git diff
- Execute `nx affected -t test`
- Run tests in parallel (up to 3 concurrent)
- Report results for each project

---

### 4. Explore Generators
```
"What Nx generators are available for creating new libraries?"
```

The Nx MCP will:
- List available generators from installed plugins
- Show @nx/js:library, @nx/react:library, etc.
- Provide generator schemas and options
- Give usage examples

---

### 5. Project Impact Analysis
```
"If I modify libs/shared/utils, which projects need to be rebuilt?"
```

The Nx MCP will:
- Trace the dependency graph
- Find all projects depending on shared/utils
- List affected applications and libraries
- Estimate rebuild impact

## Configuration

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "nx-mcp": {
      "command": "npx",
      "args": ["nx-mcp@latest"],
      "description": "Nx monorepo project graph, task management, and workspace intelligence"
    }
  }
}
```

**Arguments**:
- `nx-mcp@latest`: Official Nx MCP server (always uses latest version)
- No additional configuration required
- Automatically detects workspace at `/home/user/thalemia`

## Safety & Security

### 🔒 Security Features

1. **Workspace Scoped**
   - Operations limited to Nx workspace
   - Can't access files outside project
   - Respects Nx configuration

2. **Task Execution Control**
   - Runs tasks as defined in project.json/package.json
   - No arbitrary command execution
   - Uses existing Nx task runner

3. **Read-Heavy Operations**
   - Most operations are read-only
   - Task execution requires explicit invocation
   - No automatic modifications

### ⚠️ Safety Considerations

1. **Task Execution**
   - Running builds/tests consumes resources
   - Affected tasks may run many projects
   - Be specific about what to run

2. **Cache Implications**
   - Nx uses computation caching
   - Clear cache if getting stale results
   - Cache location: `.nx/cache/`

3. **Concurrent Execution**
   - Parallel tasks set to 3 in workspace config
   - High parallelism may overload system
   - Monitor resource usage

4. **Generator Usage**
   - Generators create/modify files
   - Review generated code
   - May affect multiple files

## Troubleshooting

### Issue: "Nx Workspace Not Found"

**Cause**: Not running in Nx workspace or nx.json missing

**Solution**:
```bash
# Verify Nx workspace
cd /home/user/thalemia
cat nx.json

# Check Nx installation
pnpm list nx

# Reinstall if needed
pnpm install
```

---

### Issue: "Project Not Found"

**Cause**: Project name misspelled or doesn't exist

**Solution**:
```bash
# List all projects
nx show projects

# Or use Nx MCP to query available projects
"List all projects in the workspace"
```

---

### Issue: "Circular Dependency Detected"

**Cause**: Two or more projects depend on each other

**Solution**:
```bash
# Visualize project graph
pnpm run graph

# Find circular dependencies
nx graph --focus=<project-name>

# Refactor to break circular dependency
# Extract shared code to new library
```

---

### Issue: "Affected Returns No Projects"

**Cause**: No changes detected or base reference incorrect

**Solution**:
```bash
# Check git status
git status

# Specify base manually
nx affected:graph --base=main

# Force rebuild all
nx run-many -t build --all
```

---

### Issue: "Cache Issues - Stale Results"

**Cause**: Nx cache contains outdated results

**Solution**:
```bash
# Clear Nx cache
pnpm run reset

# Or manually
rm -rf .nx/cache

# Run without cache
nx build <project> --skip-nx-cache
```

## Best Practices

### 1. Use Affected Commands
```bash
# Instead of rebuilding everything
✅ nx affected -t build
❌ nx run-many -t build --all

# More efficient, faster CI/CD
```

### 2. Leverage Project Tags
```json
// In project.json
{
  "tags": ["type:app", "scope:vendure", "platform:node"]
}

// Query by tags
"Show all Vendure-related projects"
```

### 3. Understand Dependencies
```
# Before removing a library
"What depends on @entrepreneur-os/shared/types?"

# If nothing depends on it, safe to remove
# If many depend on it, consider impact
```

### 4. Use Generators for Consistency
```
# Instead of manual file creation
✅ nx generate @nx/react:component ProductCard --project=ui-components
❌ Manually create files

# Ensures consistent structure
```

### 5. Monitor Task Performance
```
# Check task duration
"How long did the last build take?"

# Identify slow tasks
"Which projects take longest to build?"

# Optimize hot paths
```

## Entrepreneur-OS Specific Patterns

### Dual-Vendure Architecture
The Nx MCP understands your dual-Vendure setup:

```
apps/
├── vendure-master/       # PIM system (port 3000/3001)
├── vendure-ecommerce/    # Retail operations (port 3002/3003)
└── storefronts/          # Customer-facing apps
    ├── next-storefront/
    └── vite-storefront/
```

**Example Queries:**
- "What libraries do both Vendure instances share?"
- "What's different between vendure-master and vendure-ecommerce dependencies?"

### Shared Libraries Structure
```
libs/
├── config/               # Build configuration
├── shared/              # Cross-app utilities
│   ├── data-access/
│   ├── types/
│   ├── ui-components/
│   └── utils/
├── vendure/             # Vendure-specific extensions
│   ├── plugins/
│   ├── entities/
│   └── graphql/
└── testing/             # Testing infrastructure
```

**Example Queries:**
- "Which projects use @entrepreneur-os/shared/ui-components?"
- "Show the dependency tree for vendure/plugins"

## Integration with Other MCPs

### Nx + Filesystem MCP
```
1. Use Nx MCP: "Which file defines the ProductCard component?"
2. Use Filesystem MCP: Read the file content
3. Use Nx MCP: "What projects import ProductCard?"
```

### Nx + Git MCP
```
1. Use Git MCP: "What files changed in last commit?"
2. Use Nx MCP: "Which projects are affected by these changes?"
3. Use Nx MCP: "Run tests for affected projects"
```

### Nx + Task Master MCP
```
1. Use Task Master: "Break down feature into tasks"
2. Use Nx MCP: "Which generators can help with each task?"
3. Use Nx MCP: Execute generation and build tasks
```

## Related Documentation

- [Overview](./overview.md) - All MCP servers
- [Filesystem MCP](./filesystem-mcp.md) - File operations
- [Git MCP](./git-mcp.md) - Version control
- [CLAUDE.md](../../CLAUDE.md) - Project structure and commands
- [Nx Documentation](https://nx.dev) - Official Nx docs

## Tools Provided

The Nx MCP server provides these tools:

- `nx_docs` - Access Nx documentation sections
- `nx_available_plugins` - List available Nx plugins
- `nx_workspace_path` - Get workspace path
- `nx_workspace` - Query project graph and configuration
- `nx_project_details` - Get detailed project information
- `nx_generators` - List available code generators
- `nx_generator_schema` - Get generator options and schema
- `nx_current_running_tasks_details` - View executing tasks

## Common Workflows

### Feature Development
```
1. "What generator should I use for a new Vendure plugin?"
2. Generate code: nx g @nx/js:library vendure/plugins/my-plugin
3. "What projects need to import this to test it?"
4. "Run affected tests"
```

### Dependency Management
```
1. "Show dependency graph for vendure-master"
2. Identify problematic dependencies
3. "Can I safely update @entrepreneur-os/shared/types?"
4. "What would break if I change this interface?"
```

### Build Optimization
```
1. "Which projects take longest to build?"
2. "What's the critical path in our build?"
3. Optimize slow projects
4. "Re-run affected builds to verify improvement"
```

### Refactoring
```
1. "What depends on this component?"
2. Plan refactoring approach
3. "Which projects will be affected?"
4. "Run affected tests after changes"
```

## Performance Tips

1. **Use Computation Caching**
   - Nx caches task results
   - Rebuilds only what changed
   - Significantly faster CI/CD

2. **Parallel Execution**
   - Set in nx.json: `"parallel": 3`
   - Balance between speed and resources
   - Adjust based on system capacity

3. **Target Dependencies**
   - Define task dependencies in project.json
   - Nx runs tasks in optimal order
   - Prevents unnecessary work

4. **Remote Caching**
   - Consider Nx Cloud for team caching
   - Share computation results
   - Faster for entire team

## Limitations

1. **Single Connection**
   - Currently supports one concurrent connection
   - Sequential MCP operations only
   - May improve in future versions

2. **Stdio Mode Only**
   - Uses stdio transport (default)
   - SSE mode available with --sse flag
   - Stdio sufficient for Claude Code

3. **Version Sensitivity**
   - Uses latest version (`nx-mcp@latest`)
   - May have breaking changes
   - Pin version if stability critical

4. **Large Workspaces**
   - Very large monorepos may be slow
   - Graph queries take longer
   - Consider workspace optimization

Despite limitations, Nx MCP is **essential** for effective Entrepreneur-OS development due to the complex monorepo structure.
