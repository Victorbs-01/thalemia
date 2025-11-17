I'll analyze the repository configuration and create a comprehensive commit guide. Let me first examine the configuration files to understand the quality rules.

[15 tools called]

Now I have all the configuration information. Let me create the comprehensive commit guide for you.

## Analysis: Repository Commit Configuration

Based on my analysis of the repository configuration:

**Current Setup:**

- **Package Manager**: pnpm@9.15.4 (enforced)
- **Pre-commit Hook**: Runs lint-staged which automatically:
  - Fixes ESLint issues (with --max-warnings=0, meaning NO warnings allowed)
  - Formats code with Prettier
- **Commit Message Hook**: Validates commit messages using Conventional Commits format
- **CI Pipeline**: Runs lint → format check → type check → tests → build → e2e tests

**Note about failing commits**: I don't have access to your git history to analyze the last failing commit. However, the most common failures in this setup are:

1. **ESLint errors** that can't be auto-fixed (like using `any` type, unused variables, or console.log statements)
2. **Commit message format** violations (not following the `type: description` format)
3. **Test failures** that need to be fixed before committing
4. **Type errors** from TypeScript

---

## Complete Commit Guide

Here's the full Markdown document for your guide:

````markdown
# Practical Guide: How to Make a Commit in This Repository (Step by Step)

This guide is designed for anyone joining the team, even if you're not an experienced programmer. Follow these steps carefully, and you'll be making quality commits in no time!

## 📋 Prerequisites

Before you can make commits to this repository, make sure you have the following installed:

### Required Software

1. **Git** (for version control)
   - Windows: Download from [git-scm.com](https://git-scm.com/)
   - Mac: Run `git --version` in Terminal (will prompt installation if needed)
   - Linux: `sudo apt-get install git` (Ubuntu/Debian)

2. **Node.js** (version 20 or higher)
   - Download from [nodejs.org](https://nodejs.org/) (use LTS version)
   - Verify installation: Open terminal and run `node --version`

3. **pnpm** (our package manager - version 9.x)
   - After installing Node.js, run:

   **Linux/Mac:**

   ```bash
   npm install -g pnpm@9
   ```
````

**Windows PowerShell:**

```powershell
npm install -g pnpm@9
```

4. **A Code Editor** (we recommend):
   - **VS Code** (Visual Studio Code) - [code.visualstudio.com](https://code.visualstudio.com/)
     - Free, lightweight, and has excellent extensions for this project

### Initial Repository Setup

1. Clone the repository:

   **Linux/Mac:**

   ```bash
   git clone <repository-url>
   cd entrepreneur-os
   ```

   **Windows PowerShell:**

   ```powershell
   git clone <repository-url>
   cd entrepreneur-os
   ```

2. Install dependencies:

   **Linux/Mac/Windows:**

   ```bash
   pnpm install
   ```

3. This will automatically set up Git hooks (Husky) that help maintain code quality.

### Recommended VS Code Setup

Install these extensions in VS Code for the best experience:

1. **ESLint** (dbaeumer.vscode-eslint)
2. **Prettier - Code formatter** (esbenp.prettier-vscode)
3. **GitLens** (eamodio.gitlens) - helpful for seeing git history

**Enable auto-format on save:**

1. In VS Code, press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
2. Type "Preferences: Open Settings (JSON)"
3. Add these lines:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

This will automatically format your code and fix many issues every time you save!

---

## 🚀 Step-by-Step Process to Make a Commit

### Step 1: Create a New Branch

**Always work on a new branch, never directly on `main`!**

1. Make sure you're on the main branch and it's up to date:

   **Linux/Mac:**

   ```bash
   git checkout main
   git pull origin main
   ```

   **Windows PowerShell:**

   ```powershell
   git checkout main
   git pull origin main
   ```

2. Create and switch to a new branch with a descriptive name:

   **Linux/Mac:**

   ```bash
   git checkout -b feature/add-new-button
   ```

   **Windows PowerShell:**

   ```powershell
   git checkout -b feature/add-new-button
   ```

   **Branch naming tips:**
   - Use `feature/` prefix for new features: `feature/user-login`
   - Use `fix/` prefix for bug fixes: `fix/broken-link`
   - Use `docs/` prefix for documentation: `docs/update-readme`

### Step 2: Make Your Changes

Edit the files you need to change using your code editor (VS Code). Save your changes.

If you have auto-format on save enabled, VS Code will automatically format your code!

### Step 3: Check What Changed

Before creating a commit, always check what files you've modified:

**Linux/Mac/Windows:**

```bash
git status
```

This will show you:

- Files that have been modified (in red)
- Files ready to be committed (in green)

To see the actual changes in detail:

**Linux/Mac/Windows:**

```bash
git diff
```

### Step 4: Run Code Quality Checks

Before committing, run these commands to catch errors early:

#### 4a. Format your code

**Linux/Mac/Windows:**

```bash
pnpm run format
```

This will automatically format all your code to match the project's style guidelines.

#### 4b. Check for linting issues

**Linux/Mac/Windows:**

```bash
pnpm run lint
```

If you see errors, try to fix them automatically first:

**Linux/Mac/Windows:**

```bash
pnpm run lint:fix
```

**Common lint errors and how to fix them:**

| Error                                | What it means                  | How to fix                                             |
| ------------------------------------ | ------------------------------ | ------------------------------------------------------ |
| `no-console`                         | You used `console.log()`       | Remove it or use `console.warn()` or `console.error()` |
| `@typescript-eslint/no-explicit-any` | You used `any` type            | Specify the actual type: `string`, `number`, etc.      |
| `@typescript-eslint/no-unused-vars`  | Variable declared but not used | Remove the variable or prefix with `_`: `_unusedVar`   |

#### 4c. Run tests (if you modified code)

**Linux/Mac/Windows:**

```bash
pnpm run test
```

If you only want to test the files you changed:

**Linux/Mac/Windows:**

```bash
pnpm run test:affected
```

**What to do if tests fail:**

- Read the error message carefully - it usually tells you what's wrong
- Make sure your changes didn't break existing functionality
- If you added new functionality, you might need to update or add tests
- Ask for help from the team if you're stuck!

### Step 5: Add Files to Staging Area

Once all checks pass, add your changed files to the staging area:

**To add all changed files:**

**Linux/Mac/Windows:**

```bash
git add .
```

**To add specific files only:**

**Linux/Mac/Windows:**

```bash
git add path/to/file1.ts path/to/file2.tsx
```

**Example:**

```bash
git add apps/storefront/src/components/Button.tsx
```

### Step 6: Create the Commit

Now comes the important part: writing your commit message!

**This repository uses Conventional Commits format:**

```
type: short description

Optional longer description explaining what and why.
```

#### Commit Message Format Rules

**Structure:**

```
<type>: <description>
```

**Available types:**

| Type       | When to use                                   | Example                                       |
| ---------- | --------------------------------------------- | --------------------------------------------- |
| `feat`     | New feature                                   | `feat: add user login button`                 |
| `fix`      | Bug fix                                       | `fix: resolve broken navigation link`         |
| `docs`     | Documentation only                            | `docs: update README with setup instructions` |
| `style`    | Code formatting (no logic change)             | `style: format code with prettier`            |
| `refactor` | Code restructuring (no new features or fixes) | `refactor: simplify user validation logic`    |
| `perf`     | Performance improvement                       | `perf: optimize image loading`                |
| `test`     | Adding or updating tests                      | `test: add unit tests for login component`    |
| `build`    | Build system changes                          | `build: update webpack configuration`         |
| `ci`       | CI/CD changes                                 | `ci: add automated testing to pipeline`       |
| `chore`    | Other changes                                 | `chore: update dependencies`                  |

**Rules for the description:**

- Use lowercase (no capital letters at the start)
- No period at the end
- Keep it short and clear (under 72 characters)
- Describe WHAT you did, not HOW

**Good examples:**

```bash
git commit -m "feat: add dark mode toggle to header"
git commit -m "fix: correct price calculation in cart"
git commit -m "docs: add installation guide for Windows"
```

**Bad examples:**

```bash
git commit -m "feat: Add Dark Mode Toggle."  # ❌ Capitalized and has period
git commit -m "Fixed stuff"                   # ❌ No type prefix
git commit -m "feat"                          # ❌ No description
```

#### Creating the commit:

**Linux/Mac:**

```bash
git commit -m "feat: add new user profile page"
```

**Windows PowerShell:**

```powershell
git commit -m "feat: add new user profile page"
```

**What happens when you commit:**

1. **Pre-commit hook runs automatically:**
   - Runs ESLint to check code quality
   - Runs Prettier to format your code
   - If there are any issues, the commit will be REJECTED

2. **Commit message hook runs:**
   - Validates your commit message format
   - If format is wrong, commit will be REJECTED

### Step 7: Push Your Branch to Remote

After a successful commit, push your branch to GitHub:

**First time pushing a new branch:**

**Linux/Mac/Windows:**

```bash
git push -u origin feature/add-new-button
```

**For subsequent pushes on the same branch:**

**Linux/Mac/Windows:**

```bash
git push
```

---

## ❌ What to Do If Something Fails

### If Pre-commit Hook Fails (ESLint/Prettier errors)

You'll see error messages like:

```
❌ eslint --fix --max-warnings=0:
/path/to/file.ts
  5:12  error  Unexpected console statement  no-console
```

**How to fix:**

1. Read the error carefully - it shows:
   - The file path
   - The line number (5:12 means line 5, column 12)
   - The rule that was violated

2. Open the file in your editor
3. Navigate to the line mentioned
4. Fix the issue (remove console.log, fix type, etc.)
5. Save the file
6. Try committing again:
   ```bash
   git add .
   git commit -m "your message"
   ```

### If Commit Message Validation Fails

You'll see an error like:

```
❌ commit message must match format: type: description
```

**How to fix:**

Your commit message doesn't follow the Conventional Commits format.

**Check these common mistakes:**

- ❌ `"Fixed the bug"` → ✅ `"fix: resolve login error"`
- ❌ `"feat: Add new feature."` → ✅ `"feat: add new feature"` (no capital, no period)
- ❌ `"added stuff"` → ✅ `"feat: add user profile page"` (needs type prefix)

Run the commit command again with the correct format.

### If Tests Fail

```
FAIL apps/example/src/component.spec.ts
  ● Component › should render correctly
```

**How to fix:**

1. Run tests again to see the full error:

   ```bash
   pnpm run test
   ```

2. Read the error message - it usually tells you what went wrong
3. Fix the code or update the test
4. Run tests again until they pass:

   ```bash
   pnpm run test
   ```

5. Add your fixes and commit again:
   ```bash
   git add .
   git commit -m "test: fix failing component test"
   ```

### If You Need to Undo a Commit

**To undo the last commit but keep your changes:**

**Linux/Mac/Windows:**

```bash
git reset --soft HEAD~1
```

Now you can fix your changes and commit again.

**To completely discard the last commit and all changes:**

**⚠️ WARNING: This cannot be undone!**

**Linux/Mac/Windows:**

```bash
git reset --hard HEAD~1
```

---

## 🌐 Creating a Pull Request on GitHub

Once you've pushed your branch, create a Pull Request (PR) to merge your changes into `main`:

1. Go to the repository on GitHub
2. You'll see a yellow banner saying "Compare & pull request" - click it
3. Fill in the PR description:
   - **Title**: Use the same format as commit messages: `feat: add user profile page`
   - **Description**: Explain:
     - What you changed
     - Why you changed it
     - How to test it (if applicable)
4. Click "Create pull request"
5. Wait for the CI checks to pass (they run automatically)
6. Request a review from a team member
7. Once approved, you can merge!

**What happens during CI checks:**

The automated system will run:

1. ✅ Lint check
2. ✅ Format check
3. ✅ Type check (TypeScript)
4. ✅ Unit tests
5. ✅ Build check
6. ✅ E2E tests

If any fail, you'll see ❌ and need to fix the issues before merging.

---

## ✅ Quick Checklist Before Making a Commit

Copy this checklist and check each item before committing:

- [ ] I'm working on a branch, not on `main`
- [ ] I ran `pnpm run format` and my code is formatted
- [ ] I ran `pnpm run lint` and there are no errors
- [ ] I ran `pnpm run test` and all tests pass (if I modified code)
- [ ] I reviewed my changes with `git diff`
- [ ] I added only the files I want to commit with `git add`
- [ ] My commit message follows the format: `type: description`
- [ ] My commit message is lowercase with no period at the end
- [ ] I'm ready to push with `git push`

---

## 🆘 Need Help?

If you're stuck:

1. **Read the error message carefully** - it usually tells you what's wrong
2. **Ask a team member** - we're here to help!
3. **Check the documentation** in the `docs/` folder
4. **Search online** - Many developers have faced similar issues

Remember: Everyone makes mistakes, and the automated checks are there to help you, not to frustrate you. Take your time, read the error messages, and you'll get the hang of it quickly!

---

## 📚 Additional Resources

- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [VS Code Tips](https://code.visualstudio.com/docs)

**Happy coding! 🎉**

```

---

This guide covers everything a non-programmer needs to know to make proper commits in your repository. You can save this to `docs/guides/guia-commit.md` and reference it during onboarding!
```
