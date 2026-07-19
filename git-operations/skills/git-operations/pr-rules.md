# Pull Request Rules

## Pre-PR Validation

- Verify all commits on branch follow conventions
- Ensure all tests pass: `pnpm test:server:unit && pnpm test:server:integration`
- Confirm branch naming is correct
- Check for uncommitted changes

## PR Title Format

Must start with ticket number: `DLD-<number> <Description>`

Regex: `^DLD-[0-9]+\s.+$`

Examples:

- `DLD-123 Add Autopay Summary Endpoint`
- `DLD-456 Fix Lease Balance Calculation Bug`

## PR Template Structure

```markdown
## Context / Summary

[Brief description of what changed and why]

## Changes Made

- [Bullet point list of specific changes]

## Tests & Verification

- [ ] Unit tests passing: `pnpm test:server:unit`
- [ ] Integration tests passing: `pnpm test:server:integration`
- [ ] Linting passed: `pnpm lint`
- [ ] Type checking passed: `pnpm typecheck`
- [ ] Manual testing completed

## Test Results

[Paste relevant test output or screenshots]

## Risks / Rollback Plan

- **Risks:** [Identify potential issues]
- **Rollback:** [How to revert if needed]

## Atomicity Checklist

- [ ] Changes represent single, complete feature/fix
- [ ] All commits follow Conventional Commits format
- [ ] No unrelated changes included
- [ ] Can be described in one sentence

## Related Tickets

Closes DLD-<number>
```

## Metadata

- Base branch: Always `master`
- Labels: Infer from commit types (feat -> feature, fix -> bug, etc.)
- Reviewers: Suggest based on affected codebase areas if known

## Blocking Conditions

- Invalid branch name format
- PR title missing DLD-### prefix
- Failing quality gates
