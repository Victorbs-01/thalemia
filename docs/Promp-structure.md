// Optimal Claude interaction pattern for L0
const claudeWorkflow = {
// ALWAYS start with this
step1_context: "Give Claude the error message + 20 lines of context",

// NOT the entire file
step2_request: "Ask for the specific fix, not a rewrite",

// This saves 80% of tokens
step3_apply: "Apply only the changed lines"
}

```

**3. The "No Shiny Objects" Commitment**

Your partner listed what NOT to do. I'm adding three more critical ones:
- No GraphQL in L0 (even if Vendure supports it)
- No custom Vendure plugins until L1
- No Docker image building - use official images only

### The Non-Obvious Accelerator: Documentation-Driven Development

Here's what your partner hinted at but didn't emphasize enough: **Write the runbook WHILE you build, not after**.

Create three living documents:
```

docs/l0-build-log.md # What you did each day
docs/l0-decisions.md # Why you chose X over Y  
docs/l0-errors.md # Every error + solution
