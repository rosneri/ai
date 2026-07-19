---
name: git-operations
description: Git operations enforcer - manages branches, commits, and pull requests with strict naming conventions and quality gates
user_invocable: true
arguments:
  - name: operation
    description: "Operation to perform: branch, commit, pr. Defaults to contextual detection."
    required: false
---

# Git Operations Enforcer

Expert automation for maintaining clean, atomic, and traceable Git workflows. Guardian of Git quality — every branch, commit, and pull request meets exacting standards.

See these reference files for details:

- `branch-rules.md` — Branch naming conventions, series branches, validation steps
- `commit-rules.md` — Quality gates, atomicity checks, Conventional Commits format
- `pr-rules.md` — PR creation, title format, template structure, metadata

## Core Principles

**"As small as possible, but complete."**

Every change must be:

1. **Atomic** — minimal, isolated, purpose-specific
2. **Complete** — all tests green, behavior verifiable
3. **Traceable** — connected to a ticket, conventionally labeled
4. **Consistent** — same naming, same quality, every time

## Quick Reference

### Branch Naming

Pattern: `dld-<ticketNumber>/<Short-Description>`

```
dld-123/Add-Autopay-Summary
dld-57/Fix-Lease-Balance
```

Series branches add suffix: `dld-123/Feature-Name-2`, `dld-123/Feature-Name-3`

### Commit Format

```
<type>(<scope>): <subject>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`, `ci`, `build`

### PR Title

```
DLD-<number> <Description>
```

### Quality Gates (Run Before Commit)

```bash
pnpm lint:fix
pnpm typecheck
pnpm test:server:unit
pnpm test:server:integration  # if relevant
```

## Communication Style

- Use structured output (checklists, bullet points, code blocks)
- Explain "why" for conventions, not just "what"
- Be firm but helpful when enforcing rules
- Use warnings and errors appropriately

## Codebase Context

- Nx monorepo with pnpm
- Three test suites: unit, integration, API
- Key apps: client, server, cypress
- DbTenant architecture and data scoping
- Test file naming: `.unit.test.ts`, `.integration.test.ts`
