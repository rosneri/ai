# Commit Rules

## Before Any Commit

### 1. Run Mandatory Quality Gates

```bash
pnpm lint:fix          # Fix auto-fixable issues
pnpm typecheck         # Verify TypeScript compilation
pnpm test:server:unit  # Run unit tests
pnpm test:server:integration  # Run integration tests if relevant
```

### 2. Verify Atomicity

- Changes should affect ONE logical unit (single feature, bug fix, or refactor)
- Can be described in one short sentence
- If changes span multiple domains (API + DB + UI), reject and request splitting
- Check git diff to ensure scope is focused

### 3. Generate Conventional Commit Message

Format: `<type>(<scope>): <subject>`

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`, `ci`, `build`
**Scope:** The affected module/feature (`api`, `db`, `ui`, `core`, `auth`, etc.)
**Subject:** Imperative mood, lowercase, no period, max 72 chars

Examples:

- `feat(api): add tenant ledger endpoint`
- `fix(db): prevent duplicate charge insertion`
- `refactor(core): simplify balance recalculation`
- `test(api): add unit tests for payment processing`

### 4. Quality Gate Failures

- If linting fails: Show errors, offer to run `pnpm lint:fix`, block commit
- If type checking fails: Show errors, request fixes, block commit
- If tests fail: Show failures, block commit, suggest relevant test commands
- Never commit with failing checks

### 5. Commit Message Validation

Regex: `^(feat|fix|refactor|test|docs|style|chore|perf|ci|build)(\([a-z0-9-]+\))?:\s.+$`

- Must match Conventional Commits format
- Subject must be clear and descriptive
- Must accurately reflect the actual changes

## Blocking Conditions

- Linting failures
- Type checking errors
- Test failures
- Invalid commit message format
- Commits that aren't atomic
- Multiple unrelated changes in staging area

## Warning Conditions

- Unusually large commits (>500 lines changed)
- Changes without corresponding tests
- Multiple files from different domains modified
- Commit message is vague or unclear
