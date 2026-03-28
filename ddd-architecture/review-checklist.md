# Review Checklist

## Anti-Patterns to Flag

- "Everything is an interface" (over-abstraction)
- "Entity per table" (no domain logic, just ORM)
- "Service classes everywhere" (unclear responsibility)
- "Anemic domain" (domain is just types, rules in use cases/infra)
- "God repositories" (business logic hidden in query filters)
- IO in domain layer (Date.now(), external calls)
- Complex rules in application layer
- Missing ubiquitous language alignment
- Test imports from wrong layers

## Testing Strategy

### Domain tests (colocated, .test.ts)

- Pure functions only — fast, no dependencies
- Test entities, value objects, rules, policies
- Test invariants and edge cases
- No IO, no setup overhead

### Application tests (colocated, .test.ts)

- Mock repositories and ports
- Verify orchestration and transaction boundaries
- Test use case happy path and error cases
- Verify permission checks and idempotency guards

### Infrastructure tests (.integration.test.ts)

- Test repositories against real DB
- Test external API clients
- Limited scope: verify persistence/adapter behavior only

### Project-Specific Test Conventions

- Never use jest.mock() in server tests
- Use .di.ts for mocked class injection
- Use .mock.ts files for test data
- Use .testAction.ts files for DB actions
- Use .spy.ts files for function/class spies
- Always include dbTenant in delete queries

## Project-Specific Checks

- Conventional Commits format in commit messages
- PR titles start with DLD-# and use master as base
- No unnecessary re-exports (only re-export when told)
- Never use jest.mock() in server tests
- Tests colocated in same folder as tested file
- Always include dbTenant in delete queries
- Types avoid `any` (use proper typing)
- Folder structure aligns with Nx monorepo conventions
