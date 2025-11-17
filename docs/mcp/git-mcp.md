# Git MCP Server

The Git MCP server provides comprehensive Git repository operations, enabling Claude Code to interact with version control systems for code management, history analysis, and collaboration workflows.

## What It Does

The Git MCP enables Claude Code to:
- Read commit history and branch information
- Analyze code changes and diffs
- Search through Git history
- Manage branches and tags
- Inspect repository status
- Review merge conflicts and history

All operations are **scoped to the configured repository** (`/home/user/thalemia`) for security.

## When to Use It

### ✅ Use Git MCP When:

1. **Analyzing Commit History**
   - Reviewing recent changes
   - Finding when a feature was added
   - Understanding code evolution
   - Investigating bug origins with git blame

2. **Branch Management**
   - Listing all branches
   - Comparing branches
   - Checking branch status
   - Finding merged/unmerged branches

3. **Code Archaeology**
   - Finding commits by author or message
   - Tracking file history
   - Understanding why code changed
   - Reviewing pull request history

4. **Diff Analysis**
   - Comparing code between commits
   - Reviewing changes in feature branches
   - Understanding impact of changes
   - Validating merge results

5. **Repository Insights**
   - Contributor statistics
   - File change frequency
   - Identifying hotspots
   - Code ownership analysis

## When NOT to Use It

### ❌ Do NOT Use Git MCP When:

1. **Making Destructive Changes**
   - Force pushes
   - Rewriting public history
   - Hard resets
   - Use git commands directly with caution

2. **Complex Interactive Operations**
   - Interactive rebase
   - Interactive staging
   - Conflict resolution UI
   - Use git CLI for these

3. **Authentication-Heavy Workflows**
   - May not handle complex auth flows
   - SSH key management
   - Token rotation
   - Configure git credentials externally

4. **Submodule Management**
   - Limited submodule support
   - Complex nested repos
   - Use git submodule commands directly

5. **Git LFS Operations**
   - Large file storage operations
   - May not fully support LFS
   - Use git-lfs commands directly

## Example Prompts

### 1. Review Recent Changes
```
"Show me the last 10 commits on the current branch"
```

The Git MCP will:
- Fetch commit history
- Display commit messages, authors, dates
- Show abbreviated commit hashes
- Format for readability

---

### 2. Find Feature Origin
```
"When was the dual-Vendure pattern implemented? Show relevant commits"
```

The Git MCP will:
- Search commit messages for "dual-Vendure"
- Return matching commits with details
- Show associated file changes
- Provide timeline of implementation

---

### 3. Branch Comparison
```
"What's different between main and claude/phase-l0-1-mcp-extension-01PD99SaXL281QfngbYJ9Thn?"
```

The Git MCP will:
- Compare the two branches
- List changed files
- Show commit differences
- Summarize changes

---

### 4. Code History Analysis
```
"Show the history of CLAUDE.md file - who changed it and when?"
```

The Git MCP will:
- Run git log for CLAUDE.md
- Show all commits touching the file
- Display authors and dates
- Provide commit messages

---

### 5. Find Bug Introduction
```
"Find commits that modified the authentication plugin in the last month"
```

The Git MCP will:
- Search for relevant file paths
- Filter by time range
- Return matching commits
- Show associated changes

## Configuration

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "/home/user/thalemia"],
      "description": "Git repository operations including commits, branches, and history"
    }
  }
}
```

**Arguments**:
- `@modelcontextprotocol/server-git`: Official Git MCP package
- `--repository /home/user/thalemia`: Repository path to operate on

## Safety & Security

### 🔒 Security Features

1. **Repository Scoping**
   - Operations limited to specified repository
   - Cannot access other repositories
   - Path validation prevents traversal

2. **Read-Heavy Design**
   - Primarily for reading repository state
   - Destructive operations require explicit confirmation
   - No automatic force operations

3. **User Permissions**
   - Runs with current user's Git permissions
   - Respects Git configuration
   - Uses existing SSH keys/credentials

### ⚠️ Safety Considerations

1. **Commit Operations**
   - Review commit messages before confirming
   - Ensure correct branch before committing
   - Can't easily undo committed changes to remote

2. **Branch Management**
   - Deleting branches is permanent
   - Switching branches affects working directory
   - Unmerged changes may be lost

3. **Merge Conflicts**
   - Git MCP may have limited conflict resolution
   - Complex merges best done in CLI
   - Test merges in feature branches

4. **Remote Operations**
   - Push operations send data to remote
   - Ensure not pushing secrets or sensitive data
   - Verify remote URL before pushing

## Troubleshooting

### Issue: "Repository Not Found"

**Cause**: Invalid repository path or not a git repository

**Solution**:
```bash
# Verify repository path
cd /home/user/thalemia
git status

# Initialize if needed
git init

# Check .claude/settings.json has correct path
```

---

### Issue: "Permission Denied (publickey)"

**Cause**: SSH key not configured for remote access

**Solution**:
```bash
# Check SSH keys
ls -la ~/.ssh/

# Add SSH key to agent
ssh-add ~/.ssh/id_rsa

# Test GitHub connection
ssh -T git@github.com

# Configure Git credentials
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

---

### Issue: "Detached HEAD State"

**Cause**: Checked out a specific commit instead of branch

**Solution**:
```bash
# View current state
git status

# Return to branch
git checkout main

# Or create new branch from current state
git checkout -b feature/new-branch
```

---

### Issue: "Merge Conflict"

**Cause**: Changes conflict between branches

**Solution**:
```bash
# View conflicted files
git status

# Manual resolution
# Edit files to resolve conflicts
git add <resolved-files>
git commit

# Or abort merge
git merge --abort
```

---

### Issue: "Uncommitted Changes"

**Cause**: Working directory has uncommitted modifications

**Solution**:
```bash
# View changes
git status
git diff

# Commit changes
git add .
git commit -m "Your message"

# Or stash temporarily
git stash
# ... do other work ...
git stash pop
```

## Best Practices

### 1. Conventional Commits
```
✅ Good: "feat(vendure): add multi-tenant product sync"
✅ Good: "fix(auth): resolve session timeout issue"
❌ Avoid: "updated stuff"
❌ Avoid: "WIP"
```

See: [Conventional Commits](https://www.conventionalcommits.org/)

### 2. Meaningful Branch Names
```
✅ Good: "feature/dual-vendure-sync"
✅ Good: "fix/postgres-connection-leak"
❌ Avoid: "test"
❌ Avoid: "my-branch"
```

### 3. Atomic Commits
- One logical change per commit
- Makes history easier to understand
- Simplifies cherry-picking and reverting

### 4. Review Before Pushing
```bash
# Always review before pushing
git log origin/main..HEAD
git diff origin/main..HEAD
```

### 5. Regular Pulls
```bash
# Stay up to date with remote
git pull --rebase origin main
```

## Integration with Entrepreneur-OS Workflow

### Current Branch Strategy
As specified in your configuration, you're working on:
```
Branch: claude/phase-l0-1-mcp-extension-01PD99SaXL281QfngbYJ9Thn
```

### Git Workflow
1. **Develop** on feature branch (current: claude/phase-l0-1-mcp-extension-*)
2. **Commit** with clear, descriptive messages
3. **Push** to the specified branch when complete
4. **Create PR** when ready for review

### Safety Settings
From `.claude/settings.json`:
```json
{
  "safety": {
    "preventSecretCommits": true,
    "requireEnvValidation": true,
    "validateBeforePush": true
  }
}
```

These settings ensure:
- Secrets aren't accidentally committed
- Environment variables validated
- Changes reviewed before pushing

## Related Documentation

- [Overview](./overview.md) - All MCP servers
- [Filesystem MCP](./filesystem-mcp.md) - File operations
- [Nx MCP](./nx-mcp.md) - Monorepo awareness

## Tools Provided

The Git MCP server typically provides:

- `git_status` - Show working tree status
- `git_log` - View commit history
- `git_diff` - Show changes between commits
- `git_show` - Show commit details
- `git_branch` - List, create, or delete branches
- `git_checkout` - Switch branches
- `git_commit` - Create new commit
- `git_push` - Push changes to remote
- `git_pull` - Fetch and integrate changes
- `git_blame` - Show who last modified each line
- `git_search` - Search through commits

Exact tool names may vary by implementation version.

## Common Workflows

### Feature Development
```
1. Create feature branch: git checkout -b feature/name
2. Make changes (use Filesystem MCP)
3. Review changes: git diff
4. Commit: git commit with meaningful message
5. Push: git push -u origin feature/name
6. Create PR via GitHub
```

### Bug Investigation
```
1. Find when bug introduced: git log --grep="bug description"
2. Check file history: git log -- path/to/file
3. Identify problematic commit: git blame file.ts
4. Review changes: git show <commit-hash>
5. Create fix in new branch
```

### Code Review
```
1. Fetch latest: git fetch origin
2. Compare branches: git diff main...feature
3. Review commits: git log main..feature
4. Check specific files: git diff main feature -- file.ts
5. Provide feedback
```

## Advanced Usage

### Search Commits by Content
```
"Find all commits that added Redis configuration"
```

### Contributor Analysis
```
"Show commit statistics by author for the last 3 months"
```

### File Evolution
```
"Show how docker-compose.yml has changed over time"
```

### Branch Cleanup
```
"List all branches that have been merged to main"
```

These advanced features help maintain repository health and understand project evolution.
