# DDD Patterns — When to Use

## Value Objects (Use Sparingly)

- **Use when** validation repeats (Money, Percent, Email, DateRange)
- **Use when** equality is by value, not identity
- **Skip when** it's just a primitive with no rules
- **Test:** Does this VO protect an invariant? If not, it's premature.

## Entities & Aggregates (Use Only When Protecting Invariants)

- **Use when** there is identity + meaningful lifecycle
- **Use when** multiple fields must change together under rules
- **Skip when** it's just a DB row with no meaningful rules (use a plain type)
- **Test:** Does this entity have invariants worth protecting?

## Domain Services / Policies

- **Use when** a rule spans multiple entities and doesn't belong to one
- **Use when** complex validation/calculation logic emerges
- **Skip for** application orchestration (that's a use case)
- **Skip for** generic "helper" functions

## Repositories & Ports

Define a port (interface) only when:

- You'll have multiple implementations (Mongo vs Postgres, fake vs real)
- You need isolation for tests
- You want domain free of persistence concerns

Skip port when:

- It's stable and unlikely to change
- Use case can depend directly on repo (still keep out of domain)

**Pragmatic rule:** external services (Stripe, email, queue) -> port; internal volatile -> port optional; internal stable -> skip until pain

## CQRS Pattern (Lightweight)

- Command files: type definition only (interface or type)
- Query files: type definition only
- Use case files: handler logic — `execute(command/query): Promise<Result>`
- Use cases should be thin: load -> apply rules -> persist -> return
- No passing request objects through layers

## Ubiquitous Language & Invariants

- Code should reflect clear, consistent domain terms
- Invariants should be explicitly stated ("A charge can't change amount after posting")
- Invariant violations raise specific domain errors, not generic exceptions
- Ambiguous naming suggests unclear domain understanding

## Error Handling

- Domain errors for business violations (specific exceptions)
- Input validation at edge (controller) or start of use case
- Avoid duplicating validation across layers
- Error names should match domain violations (`ChargeAlreadyPosted`, `InsufficientFunds`)
