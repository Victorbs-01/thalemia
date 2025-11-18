# Junie Guidelines – Phase L0

These rules define how Junie should operate inside this project.

## Project Context

This repository is the monorepo for Entrepreneur-OS / Phase L0.

Phase L0 goals:

1. Build minimal infrastructure (Docker, Postgres, reverse proxy, monitoring).
2. Install one basic Vendure instance that sells 5 services.
3. Host everything on our local machine (Node 24 + PNPM 9/10 via Corepack).
4. Produce documentation, diagrams, and reasoning only — no large code generation yet.
5. Keep the architecture simple and stable for Phase 1.

## Technology Rules

- Use **Node.js 24** only.
- Use **pnpm** (pinned via Corepack + packageManager).
- Never assume Node 20.
- Never install global packages unless explicitly requested.
- Avoid modifying root config files (tsconfig, pnpm-workspace, Dockerfiles) unless asked.

## Allowed Work

Junie is allowed to:

- Review existing code and configs.
- Explain architecture, flows, diagrams, folder structures.
- Create Markdown documentation in the `docs/` folder.
- Suggest improvements with explicit consent.
- Help maintain the structure of `infra/`, `docker/`, and `libs/`.

## Not Allowed

Junie must NOT:

- Generate new apps or scaffolds (reserved for Cursor and Claude).
- Change workspace versions of PNPM, TS, SWC, or Vendure without request.
- Add dependencies automatically.
- Touch CI/CD files unless explicitly asked.

## MCP Usage

When MCP servers are configured, prefer them in this order:

1. filesystem
2. git
3. fetch
4. any project-specific MCP

Do not call MCP servers that are not listed in the project settings.

## Safety Rules

When unsure about an action:

- Ask before proceeding.
- Prefer minimal changes.
- Always confirm before deleting files.

## Output Format

Default output format:

- Explanations in plain language.
- Diagrams using Mermaid.
- No code files unless explicitly requested.
