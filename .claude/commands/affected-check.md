# Affected Check

Show what projects are affected by the current changes using Nx:

1. Run `nx affected:graph` to visualize affected projects
2. List affected projects for:
   - Build targets
   - Test targets
   - Lint targets
   - E2E targets
3. Show the dependency tree explaining why projects are affected
4. Estimate the impact scope (number of projects, lines of code)

This helps understand the blast radius of your changes before committing or creating a PR.
