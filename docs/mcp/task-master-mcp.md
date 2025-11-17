# Task Master MCP Server ✨ NEW

The Task Master MCP server provides AI-powered task management capabilities, enabling Claude Code to parse product requirements, decompose complex tasks, maintain task registries, and orchestrate multi-step development workflows.

## What It Does

The Task Master MCP enables Claude Code to:
- **Parse PRDs**: Extract structured tasks from product requirement documents
- **Decompose tasks**: Break complex features into manageable subtasks
- **Manage task registry**: Track tasks, statuses, and dependencies
- **Coordinate workflows**: Orchestrate multi-step development processes
- **Prioritize work**: Determine next actionable task
- **Track progress**: Monitor task completion and blockers

This tool bridges **planning and execution**, turning requirements into actionable development tasks.

## When to Use It

### ✅ Use Task Master MCP When:

1. **Planning New Features**
   - Breaking down feature requirements
   - Creating implementation roadmaps
   - Estimating complexity and effort
   - Identifying dependencies

2. **Complex Multi-Step Projects**
   - Large refactoring efforts
   - New application scaffolding
   - Infrastructure migrations
   - Multi-component features

3. **PRD/Requirements Analysis**
   - Parsing product requirement documents
   - Extracting actionable tasks
   - Validating completeness
   - Identifying ambiguities

4. **Progress Tracking**
   - Monitoring task completion
   - Identifying blockers
   - Reporting status
   - Maintaining development log

5. **Team Coordination**
   - Sharing task breakdowns
   - Delegating work items
   - Tracking parallel workstreams
   - Maintaining project context

## When NOT to Use It

### ❌ Do NOT Use Task Master MCP When:

1. **Simple Single Tasks**
   - One-step operations (use direct commands)
   - Quick fixes or updates
   - Trivial changes
   - Overhead not justified

2. **Immediate Execution**
   - Need to run commands right away
   - No planning phase needed
   - Task is self-contained
   - Use appropriate MCP directly

3. **File Operations**
   - Reading/writing files → Use Filesystem MCP
   - Code editing → Use Filesystem MCP
   - Not task management

4. **Version Control**
   - Git operations → Use Git MCP
   - Commit management → Use Git MCP
   - Not related to task planning

5. **External Project Management**
   - Jira/Linear integration → Use their APIs
   - GitHub Issues → Use GitHub CLI
   - Task Master is internal to repo

## Example Prompts

### 1. Parse Product Requirements
```
"Parse this PRD and break it into development tasks:
We need a multi-tenant product sync feature that replicates products from vendure-master
to vendure-ecommerce instances, with support for selective sync, conflict resolution,
and audit logging."
```

The Task Master MCP will:
- Analyze the requirements
- Extract key features and capabilities
- Break down into logical tasks
- Identify dependencies
- Suggest implementation order
- Store in task registry

---

### 2. Decompose Complex Task
```
"Break down the task 'Implement authentication plugin' into subtasks with dependencies"
```

The Task Master MCP will:
- Analyze the high-level task
- Create subtasks (schema, entities, resolvers, tests)
- Identify dependencies between subtasks
- Estimate complexity
- Suggest optimal order
- Update task registry

---

### 3. Get Next Actionable Task
```
"What's the next task I should work on?"
```

The Task Master MCP will:
- Review task registry
- Check task statuses and dependencies
- Identify unblocked tasks
- Consider priority levels
- Recommend next task
- Provide context and acceptance criteria

---

### 4. Update Task Status
```
"Mark task 'Create ProductEntity' as completed"
```

The Task Master MCP will:
- Find task in registry
- Update status to completed
- Check dependent tasks
- Unblock downstream tasks
- Update progress metrics
- Suggest next steps

---

### 5. Analyze Project Progress
```
"Show me the status of all tasks for the dual-Vendure sync feature"
```

The Task Master MCP will:
- Filter tasks by feature/tag
- Report completion status
- Identify blockers
- Calculate progress percentage
- List pending tasks
- Highlight risks or issues

## Configuration

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "task-master": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      },
      "description": "AI-powered task management with PRD parsing and task decomposition"
    }
  }
}
```

**Arguments**:
- `task-master-ai`: npm package name
- `-y`: Auto-accept installation prompts

**Environment Variables**:
- `ANTHROPIC_API_KEY`: For Claude models (preferred)
- `OPENAI_API_KEY`: For OpenAI models (alternative)
- At least ONE API key required
- Supports seamless provider switching

## Safety & Security

### 🔒 Security Features

1. **Local Task Storage**
   - Tasks stored in repository
   - Version controlled alongside code
   - Team-accessible and auditable

2. **API Key Protection**
   - Keys in environment variables only
   - Never committed to repository
   - Uses existing .env infrastructure

3. **Read-Only Requirements**
   - Can read PRD documents
   - Doesn't modify source code
   - Only manages task data

### ⚠️ Safety Considerations

1. **API Costs**
   - Uses AI APIs for task decomposition
   - Each operation incurs cost
   - Monitor API usage
   - Consider cost vs. benefit

2. **API Key Management**
   - Keep keys secure
   - Don't share or commit
   - Rotate regularly
   - Use separate keys for dev/prod

3. **Task Accuracy**
   - AI-generated task breakdowns
   - Review for completeness
   - Validate assumptions
   - Human oversight recommended

4. **Dependency Analysis**
   - AI infers task dependencies
   - May miss implicit dependencies
   - Verify before execution
   - Update as needed

## Environment Setup

### 1. Add API Keys to .env

```bash
# In /home/user/thalemia/.env
ANTHROPIC_API_KEY=sk-ant-api03-xxx...
OPENAI_API_KEY=sk-proj-xxx...  # Optional alternative
```

### 2. Verify Configuration

```bash
# Check environment variables
echo $ANTHROPIC_API_KEY

# Test Task Master
# (Will auto-install via npx on first use)
```

### 3. API Key Sources

**Anthropic API Key**:
- Sign up at https://console.anthropic.com
- Create API key in settings
- Supports Claude 3.5 Sonnet (recommended)

**OpenAI API Key** (alternative):
- Sign up at https://platform.openai.com
- Create API key in settings
- Supports GPT-4 and GPT-3.5

Choose based on:
- Model preference
- Pricing
- Rate limits
- Feature support

## Troubleshooting

### Issue: "API Key Not Found"

**Cause**: Environment variable not set

**Solution**:
```bash
# Check if .env exists
ls -la /home/user/thalemia/.env

# Add API key
echo 'ANTHROPIC_API_KEY=your-key-here' >> .env

# Or export directly
export ANTHROPIC_API_KEY=your-key-here

# Restart Claude Code to load new env
```

---

### Issue: "API Rate Limit Exceeded"

**Cause**: Too many requests in short time

**Solution**:
- Wait before retrying (rate limits reset)
- Reduce frequency of task operations
- Batch similar operations
- Upgrade API tier if needed

---

### Issue: "Invalid API Response"

**Cause**: API error or malformed request

**Solution**:
- Verify API key is valid
- Check API service status
- Retry the operation
- Check for service outages

---

### Issue: "Task Registry Not Found"

**Cause**: Task storage not initialized

**Solution**:
```bash
# Task Master creates registry on first use
# If missing, initialize manually:
mkdir -p .task-master
touch .task-master/registry.json

# Or let Task Master create on first operation
```

---

### Issue: "Provider Switching Fails"

**Cause**: Both API keys invalid or missing

**Solution**:
- Ensure at least ONE valid API key
- Test key validity:
  ```bash
  # For Anthropic
  curl https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY"
  ```
- Check for typos in .env file

## Best Practices

### 1. Start with High-Level Tasks
```
✅ Good: "Implement multi-tenant product sync"
❌ Avoid: "Add line 42 to file X"

# Let Task Master decompose into details
```

### 2. Provide Context in PRDs
```
# Include:
- User stories
- Acceptance criteria
- Technical constraints
- Dependencies
- Performance requirements
```

### 3. Review AI Suggestions
```
# Task Master uses AI to:
- Parse requirements
- Suggest tasks
- Estimate complexity

# Always review and adjust based on:
- Domain knowledge
- Technical constraints
- Team capacity
```

### 4. Update Status Regularly
```
# Keep task registry current:
- Mark completed tasks
- Update blockers
- Revise estimates
- Add new subtasks discovered
```

### 5. Use Task Tags/Labels
```
# Organize tasks by:
- Feature area (dual-vendure, auth, ui)
- Priority (high, medium, low)
- Component (master, ecommerce, shared)
- Type (feature, bug, refactor)
```

## Integration with Entrepreneur-OS

### Task Storage Location
```
/home/user/thalemia/.task-master/
├── registry.json        # Main task database
├── history/            # Task history and changes
└── templates/          # Task templates
```

**Note**: Add to .gitignore if tasks are sensitive, or commit for team visibility.

### Typical Workflow

1. **Feature Planning**
   ```
   PRD → Task Master → Task breakdown → Review → Execute
   ```

2. **Development Cycle**
   ```
   Get next task → Implement → Update status → Repeat
   ```

3. **Progress Reporting**
   ```
   Query task status → Generate report → Share with team
   ```

### Example: Dual-Vendure Sync Feature

```
1. Parse PRD:
   "Parse the dual-Vendure product sync requirements from docs/Plans/..."

2. Review Tasks:
   Task Master creates:
   - Create sync service
   - Implement n8n workflow
   - Add conflict resolution
   - Create audit logging
   - Write tests
   - Update documentation

3. Execute:
   "What's next?" → Implement → "Mark completed" → Repeat

4. Track:
   "Show sync feature progress" → Review → Adjust priorities
```

## Tool Modes

Task Master supports multiple tool modes for optimization:

### Core Mode (Minimal)
- Essential tools only
- Lower token usage
- Faster responses
- Good for simple tasks

### Standard Mode (Default)
- Balanced tool set
- Most common operations
- Recommended for general use

### All Mode (Comprehensive)
- All available tools
- Maximum capability
- Higher token usage
- Use for complex planning

Mode is configurable in Task Master settings (see documentation).

## Related Documentation

- [Overview](./overview.md) - All MCP servers
- [Nx MCP](./nx-mcp.md) - Monorepo awareness
- [Git MCP](./git-mcp.md) - Version control
- [TODO.md](../../docs/TODO.md) - Current project tasks
- [Masterplan.md](../../docs/Plans/Masterplan.md) - Project roadmap

## Tools Provided

The Task Master MCP server provides:

- `get_tasks` - Retrieve task list (all or filtered)
- `next_task` - Get next actionable task
- `set_task_status` - Update task status
- `parse_prd` - Parse product requirements document
- `expand_task` - Decompose task into subtasks
- `add_task` - Create new task
- `update_task` - Modify existing task
- `delete_task` - Remove task from registry
- `get_progress` - Calculate completion metrics

Exact tools depend on version and mode.

## Common Workflows

### Planning New Feature
```
1. Write or paste PRD
2. "Parse this PRD and create task breakdown"
3. Review suggested tasks
4. Refine and adjust
5. Begin execution
```

### Daily Development
```
1. "What's next?"
2. Get task details
3. Implement using appropriate MCPs
4. "Mark task X completed"
5. Repeat
```

### Progress Review
```
1. "Show feature X progress"
2. Review completed/pending
3. Identify blockers
4. Adjust priorities
5. Report to team
```

### Refactoring Project
```
1. "Break down refactoring of Vendure plugins"
2. Review task dependencies
3. Execute in dependency order
4. Track progress
5. Validate completion
```

## Advanced Usage

### Custom Task Templates
Create reusable templates for common task types:
```json
{
  "template": "vendure-plugin",
  "subtasks": [
    "Create plugin class",
    "Define entities",
    "Add GraphQL resolvers",
    "Write unit tests",
    "Write E2E tests",
    "Update documentation"
  ]
}
```

### Dependency Chains
Express complex dependencies:
```
Task A → Task B → Task C
         Task B → Task D

"Task B" blocks both C and D
Completing B unblocks both
```

### Priority Scoring
Task Master can prioritize based on:
- Business value
- Urgency
- Complexity
- Dependencies
- Resource availability

### Integration with CI/CD
Link tasks to:
- Git branches
- Pull requests
- Build status
- Test results

## Cost Considerations

Task Master uses AI APIs which have costs:

**Anthropic Claude**:
- Sonnet 4: ~$3/million input tokens
- Best for complex task decomposition

**OpenAI GPT**:
- GPT-4: ~$30/million input tokens (higher cost)
- GPT-3.5: ~$0.50/million input tokens (budget option)

**Typical Usage**:
- Parse PRD: ~2,000-5,000 tokens
- Expand task: ~1,000-3,000 tokens
- Get next task: ~500-1,000 tokens

**Monthly Estimate**:
- Light use: <$1
- Medium use: $1-5
- Heavy use: $5-20

Monitor via API provider dashboard.

## Future Enhancements

Task Master is actively developed. Planned features:

- GitHub Issues integration
- Linear/Jira sync
- Team collaboration features
- Advanced analytics
- Custom workflows
- Template marketplace

Check package updates for new capabilities.
