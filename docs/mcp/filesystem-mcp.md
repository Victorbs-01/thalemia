# Filesystem MCP Server

The Filesystem MCP server provides secure, controlled access to file system operations within the Entrepreneur-OS workspace.

## What It Does

The Filesystem MCP enables Claude Code to:
- Read and write files within the allowed directory
- Create, move, and delete files and directories
- Search for files and directories
- Get file metadata (size, permissions, modification time)

All operations are **restricted to the workspace directory** (`/home/user/thalemia`) for security.

## When to Use It

### ✅ Use Filesystem MCP When:

1. **Reading project files**
   - Reading source code for analysis
   - Reviewing configuration files
   - Examining documentation

2. **Writing or modifying files**
   - Creating new components or modules
   - Updating configuration
   - Editing source code

3. **File system operations**
   - Creating directory structures
   - Moving files between locations
   - Deleting temporary or obsolete files

4. **Searching for files**
   - Finding files by name or pattern
   - Locating configuration files
   - Discovering project structure

5. **Batch operations**
   - Processing multiple files
   - Renaming files in bulk
   - Organizing project directories

## When NOT to Use It

### ❌ Do NOT Use Filesystem MCP When:

1. **Outside workspace boundary**
   - Cannot access files outside `/home/user/thalemia`
   - Use native system commands if you need system-wide access

2. **Binary file manipulation**
   - Not designed for binary files (images, PDFs, compiled binaries)
   - May have issues with encoding

3. **Large file operations**
   - Reading very large files (>10MB) may be slow
   - Consider streaming or chunking approaches

4. **Real-time file watching**
   - MCP is request-response, not event-driven
   - Use file watching tools for monitoring changes

5. **System administration tasks**
   - No sudo/root access
   - Cannot modify system files
   - Use appropriate system tools instead

## Example Prompts

### 1. Reading Project Structure
```
"Show me the structure of the apps/ directory and list all applications"
```

The Filesystem MCP will:
- List directories in `apps/`
- Provide file counts and structure overview
- Identify application entry points

---

### 2. Creating New Component
```
"Create a new React component called ProductCard in libs/shared/ui-components/src/"
```

The Filesystem MCP will:
- Create the component file with proper structure
- Add TypeScript interfaces
- Export the component from index.ts

---

### 3. Searching Configuration
```
"Find all tsconfig.json files in the project"
```

The Filesystem MCP will:
- Search recursively for tsconfig files
- List all matches with full paths
- Optionally read contents if requested

---

### 4. Batch File Operations
```
"Rename all .spec.ts files in libs/vendure/plugins to .test.ts"
```

The Filesystem MCP will:
- Find all matching files
- Rename each file
- Update any imports if needed
- Provide summary of changes

---

### 5. Cleaning Up
```
"Delete all .log files in the project, excluding node_modules"
```

The Filesystem MCP will:
- Search for .log files
- Exclude ignored directories
- Delete matched files
- Report number of files removed

## Configuration

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/thalemia"],
      "description": "Secure file system operations with read/write access to the workspace"
    }
  }
}
```

**Arguments**:
- `@modelcontextprotocol/server-filesystem`: Official Filesystem MCP package
- `/home/user/thalemia`: Allowed directory (workspace root)

## Safety & Security

### 🔒 Security Features

1. **Directory Restriction**
   - All operations scoped to `/home/user/thalemia`
   - Cannot access parent directories or system files
   - Path traversal attacks prevented

2. **No Sudo/Root**
   - Runs with user permissions only
   - Cannot modify system configuration
   - Cannot access protected files

3. **Explicit Operations**
   - All file operations require explicit commands
   - No automatic or background operations
   - Changes are traceable and reviewable

### ⚠️ Safety Considerations

1. **Destructive Operations**
   - Delete and move operations are permanent
   - Always confirm before bulk deletions
   - Use version control (Git) for recoverability

2. **Sensitive Files**
   - Be cautious with `.env` files and secrets
   - Don't expose API keys or credentials
   - Review changes before committing

3. **Large Operations**
   - Batch operations on many files can be slow
   - Consider impact on Nx cache and build artifacts
   - Test on small subset first

## Troubleshooting

### Issue: "Permission Denied"

**Cause**: File or directory has restricted permissions

**Solution**:
```bash
# Check file permissions
ls -la /path/to/file

# Fix permissions if needed (be careful!)
chmod 644 /path/to/file  # For files
chmod 755 /path/to/directory  # For directories
```

---

### Issue: "Path Not Found"

**Cause**: File or directory doesn't exist, or typo in path

**Solution**:
- Verify path with `ls` command
- Check for typos in file/directory names
- Ensure using absolute paths when needed

---

### Issue: "Cannot Access Outside Workspace"

**Cause**: Attempting to access files outside `/home/user/thalemia`

**Solution**:
- Filesystem MCP is restricted to workspace
- Use native Bash commands if system access needed
- Consider if operation truly needs to be outside workspace

---

### Issue: "File Already Exists"

**Cause**: Attempting to create file that already exists

**Solution**:
- Use edit/modify operations instead
- Delete existing file first (with caution)
- Choose different filename

---

### Issue: "Encoding Error"

**Cause**: File has non-UTF-8 encoding or binary content

**Solution**:
- Filesystem MCP works best with text files
- Use appropriate tools for binary files
- Convert encoding if possible: `iconv -f ISO-8859-1 -t UTF-8`

## Best Practices

### 1. Use Relative Paths
```
✅ Good: "libs/shared/utils/src/formatPrice.ts"
❌ Avoid: "/home/user/thalemia/libs/shared/utils/src/formatPrice.ts"
```

### 2. Respect .gitignore
- Don't modify files in `node_modules/`
- Avoid changing `.nx/cache/` contents
- Leave `dist/` and build artifacts alone

### 3. Leverage Project Structure
- Follow Nx monorepo conventions
- Use `@entrepreneur-os/` import paths
- Maintain consistent file organization

### 4. Backup Before Bulk Operations
```bash
# Create branch before major changes
git checkout -b feature/restructure-components
```

### 5. Verify Changes
- Review file contents after writing
- Use Git diff to see changes
- Test affected functionality

## Related Documentation

- [Overview](./overview.md) - All MCP servers
- [Git MCP](./git-mcp.md) - Version control operations
- [Nx MCP](./nx-mcp.md) - Monorepo project graph

## Tools Provided

The Filesystem MCP server typically provides these tools:

- `read_file` - Read file contents
- `write_file` - Write or create file
- `list_directory` - List directory contents
- `create_directory` - Create new directory
- `move_file` - Move or rename file
- `delete_file` - Delete file
- `get_file_info` - Get file metadata
- `search_files` - Search for files by pattern

Exact tool names may vary by implementation version.
