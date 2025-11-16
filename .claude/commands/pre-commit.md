# Pre-commit Checks

Run all pre-commit checks manually (same as what git hooks will run):

1. Run lint-staged on currently staged files
2. Run ESLint with --fix on changed files
3. Run Prettier formatting on changed files
4. Run TypeScript type checking
5. Verify conventional commit message format (if provided)

This allows you to test pre-commit hooks without actually committing.

Report any issues found and suggest fixes.
