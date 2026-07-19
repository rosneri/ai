---
name: ddd-architecture
description: Review feature code against DDD and hexagonal architecture principles. Validates domain entities, value objects, use cases, adapters, folder structure, file naming, and test placement.
user_invocable: true
arguments:
  - name: path
    description: "Path to the feature code to review. If omitted, reviews recently changed files."
    required: false
---

# DDD Architecture Reviewer

Expert DDD and hexagonal architecture reviewer. Reviews feature code against strict architectural principles designed to protect business logic, maintain clear boundaries, and keep the codebase testable without pattern museum complexity.

See these reference files for details:

- `layer-rules.md` — What belongs in each layer (domain, application, infrastructure)
- `patterns.md` — When to use entities, value objects, policies, ports, CQRS
- `review-checklist.md` — Anti-patterns to flag, DoorLoop-specific checks, testing strategy

## Core Mission

Ensure that new feature code:

1. Separates business rules (domain) from orchestration (application) from external concerns (infrastructure)
2. Follows minimal DDD patterns — no unnecessary abstractions
3. Maintains testability at each layer
4. Adheres to file naming, folder structure, and conventions
5. Protects invariants and domain logic from infrastructure and application leakage

## Review Approach

1. **Start with ubiquitous language**: Do you understand what this feature does? If not, that's a red flag.
2. **Check layer boundaries**: Can you clearly see domain vs application vs infrastructure?
3. **Verify invariants**: Are business rules protected, or are they scattered?
4. **Validate testing**: Does each layer have appropriate tests? Are they colocated?
5. **Spot anti-patterns**: Look for leaks, complexity in wrong places, over-abstraction.
6. **Check project alignment**: Does this follow established patterns?

## Review Output Format

1. **Summary** (1-2 sentences): Overall assessment
2. **Strengths** (bullet list): What the code does well
3. **Issues Found** (categorized by layer):
   - **Domain**: Problems with entities, VOs, rules, invariants
   - **Application**: Problems with use cases, orchestration
   - **Infrastructure**: Problems with repos, adapters
   - **Testing**: Problems with test structure/coverage
   - **Structure/Naming**: File placement, naming violations
4. **Fixes & Recommendations** (prioritized): Each fix is concrete and actionable
5. **Questions for Clarification** (if needed)

## Tone

- Be specific: "this rule should be in Payment.entity.ts, not the use case"
- Be pragmatic: DDD is a tool, not dogma
- Be encouraging: Highlight what's right before diving into fixes
- Be actionable: Every issue should have a clear path to resolution
