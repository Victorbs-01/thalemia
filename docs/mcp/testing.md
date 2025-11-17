# MCP Testing Guide

This document explains how to manually verify that each MCP server is correctly configured and responding inside Claude Code.

The goal is not automated unit tests, but **quick, reliable health checks** you can run at any time.

---

## 1. Quick Health Check (All MCPs)

In Claude Code, ask:

> "List the active MCP servers in this workspace and show their names and capabilities."

You should see at least:

- Filesystem MCP
- Git MCP
- Fetch / Web MCP
- Nx MCP
- Task Master MCP

If any expected server is missing from this list, fix the configuration before continuing.

---

## 2. Filesystem MCP Tests

### 2.1 Read test

Prompt:

> "Read the file `docs/TROUBLESHOOTING.md` and summarize the first 10 lines."

Expected result:  
Claude returns a summary based on the actual content of that file without errors.

### 2.2 Write test

Prompt:

> "Create a file `docs/mcp/_test-fs.txt` with the single line: `Filesystem MCP OK`."

Then:

> "Show me the content of `docs/mcp/_test-fs.txt`."

Expected result:

- The file is created.
- The content matches exactly `Filesystem MCP OK`.

If reading works but writing fails, check filesystem permissions and the MCP configuration scope.

---

## 3. Git MCP Tests

### 3.1 Commit history test

Prompt:

> "Using the Git MCP, show me the last 3 commits in this repository (hash, author, message)."

Expected result:  
Claude shows recent commits with hashes and messages. If it fails, verify that the Git MCP is pointing at the correct repo root.

### 3.2 Diff test

Prompt:

> "Show the git diff for the last commit using the Git MCP."

Expected result:  
A diff of the latest commit is displayed. If there is an error, check that the Git repo is clean and accessible.

---

## 4. Fetch / Web MCP Tests

### 4.1 Basic HTTP fetch

Prompt:

> "Fetch `https://example.com` and show the first 200 characters of the response body."

Expected result:  
Claude returns a snippet of HTML from example.com. If it fails, check:

- Network connectivity from the machine running Claude Code
- Any proxy or firewall rules
- The Fetch MCP configuration

---

## 5. Nx MCP Tests

These tests verify that the Nx MCP can see your monorepo and interact with the project graph.

### 5.1 Project discovery

Prompt:

> "Using the Nx MCP, list all Nx projects in this workspace and group them by type (apps, libs, tools, etc.)."

Expected result:  
A list of projects that matches your `nx.json` / `project.json` structure.

### 5.2 Safe command simulation

Prompt:

> "Simulate running `nx list` via the Nx MCP and summarize the tools or plugins that are detected. Do not actually modify anything."

Expected result:  
Claude describes what `nx list` would show. If the Nx MCP cannot run or simulate commands, check:

- That Nx is installed locally
- The working directory for the MCP
- The Node/pnpm setup

---

## 6. Task Master MCP Tests

These tests assume you have a Task Registry file (for example `docs/tasks/task-registry.yaml`).

### 6.1 Read test

Prompt:

> "Using the Task Master MCP, list all tasks from the Task Registry and show them grouped by status."

Expected result:  
A structured view of tasks grouped by `todo`, `in-progress`, `done`, etc.  
If there is an error, verify that:

- The registry file path matches the MCP config
- The YAML/JSON format is valid

### 6.2 Write test (non-destructive)

Prompt:

> "Add a test task named `mcp-test-task` with status `todo` to the Task Registry using the Task Master MCP. Then show me the updated registry."

Expected result:

- A new task `mcp-test-task` appears in the registry.
- No existing tasks are corrupted or removed.

After confirming this works, you can manually remove the test task.

---

## 7. “Dry-Run” Style Testing

There is no global `/dry-run` command for MCP servers, but you can simulate operations by being explicit in your prompts:

> "Before executing anything, simulate what the MCP would do, list the planned file changes or git operations, and wait for my confirmation."

Many MCP integrations will then:

- Describe the planned changes
- Wait for an explicit confirmation before applying them

Use this pattern whenever you are unsure about potentially destructive actions.

---

## 8. Troubleshooting Checklist

If any MCP test fails:

1. **Check configuration files**

- `.claude/settings.json`
- Any MCP-specific config paths

2. **Confirm the working directory**

- Make sure the MCP is pointing at the repo root

3. **Verify dependencies**

- Node / pnpm installed and correct version
- Nx installed for the Nx MCP
- Task registry file exists for Task Master MCP

4. **Look at recent changes**

- If MCP tests used to work and now fail, inspect recent commits to config files.

5. **Document the error**

- Copy the exact error message into `docs/TROUBLESHOOTING.md` under a new section
- Add the steps you used to fix it (once resolved)

This document should be updated whenever you add new MCP servers or change their configuration.
