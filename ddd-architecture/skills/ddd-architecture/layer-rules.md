# Layer Separation Rules

## Domain Layer

### Allowed

- Pure functions (validateX, applyY, calculateZ)
- Entities with identity and lifecycle
- Value objects for repeated validation (Money, Percent, DateRange, Email)
- Domain-specific errors (InsufficientFunds, ChargeAlreadyPosted)
- Policies for rules spanning multiple entities

### Forbidden

- No IO operations (DB queries, HTTP, external APIs, Date.now())
- No infrastructure imports
- No application orchestration logic

## Application Layer

### Allowed

- Use cases that orchestrate: load state -> apply domain logic -> persist -> return result
- Command/Query definitions (type definitions only, not implementations)
- Transaction boundaries
- Permission checks and idempotency guards
- Calling external services through ports/adapters

### Forbidden

- Complex business rules (should be in domain)
- Direct DB access (must use repo)
- Mixing commands and queries in same use case

## Infrastructure Layer

### Allowed

- Repository implementations (DB operations only)
- Mappers (entity <-> DB model)
- External API clients
- Message publishers/consumers

### Forbidden

- Business logic in query filters
- Domain decisions hidden in persistence code
- Bypassing repositories from application

## Folder Structure

```
libs/<namespace>/
├─ domain/
│  ├─ <name>.entity.ts
│  ├─ <name>.entity.test.ts
│  ├─ <name>.vo.ts
│  ├─ <name>.rules.ts
│  ├─ <name>.policy.ts
│  ├─ errors.ts
│  ├─ ports.ts
│  ├─ types.ts
│  └─ index.ts
├─ application/
│  ├─ <Name>.command.ts (type only)
│  ├─ <Name>.query.ts (type only)
│  ├─ <Name>.usecase.ts (handler)
│  ├─ <Name>.usecase.test.ts
│  ├─ types.ts
│  └─ index.ts
├─ infrastructure/
│  ├─ persistence/
│  │  ├─ <name>.repository.ts
│  │  ├─ <name>.mapper.ts
│  │  └─ <name>.model.ts
│  ├─ clients/
│  │  └─ <name>.client.ts
│  ├─ messaging/
│  │  ├─ <name>.publisher.ts
│  │  └─ <name>.consumer.ts
│  └─ index.ts
└─ index.ts
```

## Naming Conventions

- Files: kebab-case (`payment-allocation.entity.ts`)
- Classes/Types: PascalCase (`PaymentAllocation`)
- Suffixes: `.entity.ts`, `.vo.ts`, `.rules.ts`, `.policy.ts`, `.command.ts`, `.query.ts`, `.usecase.ts`, `.repository.ts`, `.mapper.ts`, `.model.ts`, `.client.ts`, `.publisher.ts`, `.consumer.ts`
- Tests colocated: `<name>.<type>.test.ts` or `<name>.<type>.integration.test.ts`
- Commands/Queries use PascalCase: `AllocatePayment.command.ts`
